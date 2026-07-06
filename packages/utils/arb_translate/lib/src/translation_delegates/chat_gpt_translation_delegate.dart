import 'dart:convert';

import 'package:arb_translate/src/flutter_tools/localizations_utils.dart';
import 'package:arb_translate/src/translate_options/translate_options.dart';
import 'package:arb_translate/src/translation_delegates/translate_exception.dart';
import 'package:arb_translate/src/translation_delegates/translation_delegate.dart';
import 'package:openai_dart/openai_dart.dart' as openai;

class ChatGptTranslationDelegate extends TranslationDelegate {
  ChatGptTranslationDelegate({
    required Model model,
    required String apiKey,
    required super.batchSize,
    required super.context,
    required super.useEscaping,
    required super.relaxSyntax,
  }) : _model = model.key,
       _client = openai.OpenAIClient(
         config: openai.OpenAIConfig(
           authProvider: openai.ApiKeyProvider(apiKey),
           timeout: Duration(minutes: 2),
           retryPolicy: const openai.RetryPolicy(maxRetries: 0),
         ),
       );

  ChatGptTranslationDelegate.custom({
    required String model,
    required String apiKey,
    required Uri baseUrl,
    required super.batchSize,
    required super.context,
    required super.useEscaping,
    required super.relaxSyntax,
  }) : _model = model,
       _client = openai.OpenAIClient(
         config: openai.OpenAIConfig(
           authProvider: openai.ApiKeyProvider(apiKey),
           baseUrl: baseUrl.toString(),
           timeout: Duration(minutes: 60),
           retryPolicy: const openai.RetryPolicy(maxRetries: 0),
         ),
       );

  final String _model;
  final openai.OpenAIClient _client;

  @override
  int get maxRetryCount => 5;
  @override
  int get maxParallelQueries => 5;
  @override
  Duration get queryBackoff => Duration(seconds: 5);

  @override
  Future<String> getModelResponse(
    Map<String, Object?> resources,
    LocaleInfo locale,
  ) async {
    final encodedResources = JsonEncoder.withIndent('  ').convert(resources);

    final prompt = openai.ChatMessage.user(
      'Translate ARB messages for ${context ?? 'app'} to locale '
      '"$locale". Add other ICU plural forms according to CLDR rules if '
      'necessary. Return only raw JSON.\n\n'
      '$encodedResources',
    );

    try {
      final response = (await _client.chat.completions.create(
        openai.ChatCompletionCreateRequest(
          model: _model,
          responseFormat: _model != Model.gpt4.key
              ? openai.ResponseFormat.jsonObject()
              : null,
          messages: [prompt],
        ),
      )).text;

      if (response == null) {
        throw NoResponseException();
      }

      return response;
    } on openai.AuthenticationException catch (_) {
      throw InvalidApiKeyException();
    } on openai.RateLimitException catch (_) {
      throw QuotaExceededException();
    } on openai.ApiException catch (e) {
      if (e.statusCode == 401) {
        throw InvalidApiKeyException();
      } else if (e.statusCode == 429) {
        throw QuotaExceededException();
      }
      rethrow;
    }
  }
}
