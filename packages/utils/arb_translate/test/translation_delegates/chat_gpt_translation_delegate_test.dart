import 'dart:io';

import 'package:arb_translate/src/translate_options/translate_options.dart';
import 'package:arb_translate/src/translation_delegates/chat_gpt_translation_delegate.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final apiKey = Platform.environment['ARB_TRANSLATE_OPEN_AI_API_KEY'];
  group(
    'ChatGptTranslationDelegate',
    () {
      ChatGptTranslationDelegate createDelegate(Model model) {
        return ChatGptTranslationDelegate(
          model: model,
          apiKey: apiKey!,
          batchSize: 4096,
          context: context,
          useEscaping: false,
          relaxSyntax: false,
        );
      }

      for (final model in Model.gptModels) {
        test('returns a result from ${model.name}', () async {
          await tryTranslateWithDelegate(createDelegate(model));
        });
      }
    },
    skip: apiKey?.isNotEmpty == true ? false : 'Requires ARB_TRANSLATE_OPEN_AI_API_KEY.',
  );
}
