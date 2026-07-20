import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

import '../hook_helpers/prebuilt_rust_builder.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) {
      return;
    }

    await const HippoZstandardPrebuiltRustBuilder(
      assetName: 'src/native_bindings.g.dart',
      cratePath: 'native',
    ).run(input: input, output: output);
  });
}
