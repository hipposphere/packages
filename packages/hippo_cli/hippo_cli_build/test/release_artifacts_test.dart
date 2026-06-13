import 'package:hippo_cli_build/hippo_cli_build.dart';
import 'package:test/test.dart';

void main() {
  test('builds public storage URLs for Hippo CLI artifacts', () {
    final target = hippoCliReleaseTarget('linux', 'x64');

    expect(target.archiveName('0.1.0'), 'hippo-cli-0.1.0-linux-x64.tar.gz');
    expect(
      target.publicUri('0.1.0').toString(),
      'https://storage.hippolabs.org/hippo-cli-0.1.0-linux-x64.tar.gz',
    );
  });
}
