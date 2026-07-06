// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:arb_translate/src/flutter_tools/localizations_utils.dart';
import 'package:arb_translate/src/translate_options/translate_options.dart';
import 'package:arb_translate/src/translation_delegates/translate_exception.dart';
import 'package:arb_translate/src/translation_delegates/translation_delegate.dart';
import 'package:googleai_dart/googleai_dart.dart' as googleai;

class GeminiTranslationDelegate extends TranslationDelegate {
  GeminiTranslationDelegate({
    required Model model,
    required String apiKey,
    required super.batchSize,
    required super.context,
    required bool disableSafety,
    required super.useEscaping,
    required super.relaxSyntax,
  }) : _model = _geminiApiModel(model),
       _safetySettings = disableSafety ? _disabledSafetySettings : null,
       _client = googleai.GoogleAIClient(
         config: googleai.GoogleAIConfig.googleAI(
           authProvider: googleai.ApiKeyProvider(apiKey),
           retryPolicy: const googleai.RetryPolicy(maxRetries: 0),
         ),
       );

  GeminiTranslationDelegate.vertexAi({
    required Model model,
    required String apiKey,
    required Uri projectUrl,
    required super.batchSize,
    required super.context,
    required bool disableSafety,
    required super.useEscaping,
    required super.relaxSyntax,
  }) : _model = _vertexAiModel(model),
       _safetySettings = disableSafety ? _disabledSafetySettings : null,
       _client = googleai.GoogleAIClient(
         config: googleai.GoogleAIConfig(
           baseUrl: _vertexBaseUrl(projectUrl),
           apiMode: googleai.ApiMode.vertexAI,
           apiVersion: _vertexApiVersion(projectUrl),
           projectId: _vertexPathSegment(projectUrl, 'projects'),
           location: _vertexPathSegment(projectUrl, 'locations'),
           authProvider: googleai.BearerTokenProvider(apiKey),
           retryPolicy: const googleai.RetryPolicy(maxRetries: 0),
         ),
       );

  @override
  int get maxRetryCount => 5;
  @override
  int get maxParallelQueries => 5;
  @override
  Duration get queryBackoff => Duration(seconds: 5);

  static const _disabledSafetySettings = <googleai.SafetySetting>[
    googleai.SafetySetting(
      category: googleai.HarmCategory.harassment,
      threshold: googleai.HarmBlockThreshold.blockNone,
    ),
    googleai.SafetySetting(
      category: googleai.HarmCategory.hateSpeech,
      threshold: googleai.HarmBlockThreshold.blockNone,
    ),
    googleai.SafetySetting(
      category: googleai.HarmCategory.sexuallyExplicit,
      threshold: googleai.HarmBlockThreshold.blockNone,
    ),
    googleai.SafetySetting(
      category: googleai.HarmCategory.dangerousContent,
      threshold: googleai.HarmBlockThreshold.blockNone,
    ),
  ];

  static String _geminiApiModel(Model model) => switch (model) {
    Model.gemini15Pro || Model.gemini15Flash => '${model.key}-latest',
    Model.gemini20Flash => Model.gemini20Flash.key,
    Model.gemini20FlashLite => Model.gemini20FlashLite.key,
    Model.gemini25Pro => Model.gemini25Pro.key,
    Model.gemini25Flash => Model.gemini25Flash.key,
    Model.gemini25FlashLite => Model.gemini25FlashLite.key,
    Model.gemini3Flash => Model.gemini3Flash.key,
    Model.gemini31Pro => Model.gemini31Pro.key,
    Model.gemini31FlashLite => Model.gemini31FlashLite.key,
    _ => throw ArgumentError.value(model),
  };

  static String _vertexAiModel(Model model) => switch (model) {
    Model.gemini15Pro => model.key,
    Model.gemini15Flash => model.key,
    Model.gemini20Flash => model.key,
    Model.gemini20FlashLite => model.key,
    Model.gemini25Pro => model.key,
    Model.gemini25Flash => model.key,
    Model.gemini25FlashLite => model.key,
    Model.gemini3Flash => model.key,
    Model.gemini31Pro => model.key,
    Model.gemini31FlashLite => model.key,
    _ => throw ArgumentError.value(model),
  };

  static String _vertexBaseUrl(Uri projectUrl) => '${projectUrl.scheme}://${projectUrl.authority}';

  static googleai.ApiVersion _vertexApiVersion(Uri projectUrl) {
    if (projectUrl.pathSegments.isNotEmpty && projectUrl.pathSegments.first == 'v1beta') {
      return googleai.ApiVersion.v1beta;
    }

    return googleai.ApiVersion.v1;
  }

  static String _vertexPathSegment(Uri projectUrl, String segment) {
    final index = projectUrl.pathSegments.indexOf(segment);

    if (index == -1 || index + 1 >= projectUrl.pathSegments.length) {
      throw ArgumentError.value(
        projectUrl,
        'projectUrl',
        'Expected a Vertex AI project URL containing "$segment"',
      );
    }

    return projectUrl.pathSegments[index + 1];
  }

  static bool _isSafetyBlocked(googleai.GenerateContentResponse response) {
    if (response.promptFeedback?.blockReason == googleai.FinishReason.safety) {
      return true;
    }

    return response.candidates?.any(
          (candidate) => candidate.finishReason == googleai.FinishReason.safety,
        ) ??
        false;
  }

  final String _model;
  final List<googleai.SafetySetting>? _safetySettings;
  final googleai.GoogleAIClient _client;

  @override
  Future<String> getModelResponse(Map<String, Object?> resources, LocaleInfo locale) async {
    final encodedResources = JsonEncoder.withIndent('  ').convert(resources);
    final prompt = googleai.Content.text(
      'Translate ARB messages for ${context ?? 'app'} to locale "$locale". '
      'Add other ICU plural forms according to CLDR rules if necessary. '
      'Return only raw JSON.\n\n'
      '$encodedResources',
    );

    try {
      final response = await _client.models.generateContent(
        model: _model,
        request: googleai.GenerateContentRequest(
          contents: [prompt],
          safetySettings: _safetySettings,
        ),
      );

      if (_isSafetyBlocked(response)) {
        throw SafetyException();
      }

      final text = response.text;

      if (text == null) {
        throw NoResponseException();
      }

      return text;
    } on googleai.AuthenticationException catch (_) {
      throw InvalidApiKeyException();
    } on googleai.RateLimitException catch (_) {
      throw QuotaExceededException();
    } on googleai.ApiException catch (e) {
      if (e.statusCode == 401) {
        throw InvalidApiKeyException();
      } else if (e.statusCode == 429 ||
          e.message.startsWith('Quota exceeded') ||
          e.message.startsWith('Resource has been exhausted')) {
        throw QuotaExceededException();
      } else if (_isUnsupportedUserLocation(e.message)) {
        throw UnsupportedUserLocationException();
      }

      rethrow;
    } on googleai.GoogleAIException catch (e) {
      if (_isUnsupportedUserLocation(e.message)) {
        throw UnsupportedUserLocationException();
      }

      rethrow;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static bool _isUnsupportedUserLocation(String message) {
    return message.contains('User location is not supported') ||
        message.contains('not available in your location');
  }
}
