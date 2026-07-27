import 'package:auto_updater_linux/src/update_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const selector = LinuxUpdateSelector();

  test('selects the newest build newer than the installed build', () {
    final selected = selector.select({
      'items': [_item('100'), _item('120'), _item('110')],
    }, installedBuild: '105');

    expect(selected, containsPair('versionString', '120'));
  });

  test('does not select equal versions or downgrades', () {
    expect(
      selector.select({
        'items': [_item('99'), _item('100')],
      }, installedBuild: '100'),
      isNull,
    );
  });

  test('compares dotted numeric versions naturally', () {
    expect(selector.compareVersions('1.10', '1.9'), greaterThan(0));
    expect(selector.compareVersions('2.0', '2'), 0);
  });

  test('requires HTTPS artifact and release notes URLs', () {
    expect(
      () => selector.select({
        'items': [
          {..._item('101'), 'fileURL': 'http://example.com/app.AppImage'},
        ],
      }, installedBuild: '100'),
      throwsFormatException,
    );
    expect(
      () => selector.select({
        'items': [
          {..._item('101'), 'releaseNotesURL': 'http://example.com/notes'},
        ],
      }, installedBuild: '100'),
      throwsFormatException,
    );
  });

  test('requires a length and signature', () {
    expect(
      () => selector.select({
        'items': [
          {..._item('101')}..remove('edSignature'),
        ],
      }, installedBuild: '100'),
      throwsFormatException,
    );
    expect(
      () => selector.select({
        'items': [
          {..._item('101'), 'contentLength': 0},
        ],
      }, installedBuild: '100'),
      throwsFormatException,
    );
  });
}

Map<String, Object?> _item(String version) {
  return {
    'versionString': version,
    'fileURL': 'https://example.com/app.AppImage',
    'contentLength': 123,
    'edSignature': 'signature',
  };
}
