import 'dart:io';

import 'package:arb_translate/src/translate_options/translate_options.dart';
import 'package:arb_translate/src/translation_delegates/gemini_translation_delegate.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final geminiApiKey = Platform.environment['ARB_TRANSLATE_GEMINI_API_KEY'];
  final vertexApiKey = Platform.environment['ARB_TRANSLATE_VERTEX_AI_API_KEY'];
  final vertexProjectUrl = Platform.environment['ARB_TRANSLATE_VERTEX_AI_PROJECT_URL'];
  group('GeminiTranslationDelegate', () {
    group(
      'using Gemini API',
      () {
        GeminiTranslationDelegate createDelegate(Model model) {
          return GeminiTranslationDelegate(
            model: model,
            apiKey: geminiApiKey!,
            batchSize: 4096,
            context: context,
            disableSafety: false,
            useEscaping: false,
            relaxSyntax: false,
          );
        }

        for (final model in Model.geminiModels) {
          test('returns a result from ${model.name}', () async {
            await tryTranslateWithDelegate(createDelegate(model));
          });
        }
      },
      skip: geminiApiKey?.isNotEmpty == true ? false : 'Requires ARB_TRANSLATE_GEMINI_API_KEY.',
    );

    group(
      'using Vertex AI API',
      () {
        GeminiTranslationDelegate createDelegate(Model model) {
          return GeminiTranslationDelegate.vertexAi(
            model: model,
            apiKey: vertexApiKey!,
            projectUrl: Uri.parse(vertexProjectUrl!),
            batchSize: 4096,
            context: context,
            disableSafety: false,
            useEscaping: false,
            relaxSyntax: false,
          );
        }

        for (final model in Model.geminiModels) {
          test('returns a result from ${model.name}', () async {
            await tryTranslateWithDelegate(createDelegate(model));
          });
        }
      },
      skip: vertexApiKey?.isNotEmpty == true && vertexProjectUrl?.isNotEmpty == true
          ? false
          : 'Requires ARB_TRANSLATE_VERTEX_AI_API_KEY and ARB_TRANSLATE_VERTEX_AI_PROJECT_URL.',
    );
  });
}
