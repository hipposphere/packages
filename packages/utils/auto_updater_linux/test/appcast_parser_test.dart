import 'package:auto_updater_linux/src/appcast_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

void main() {
  const parser = LinuxAppcastParser();

  test('selects only the matching Linux architecture and default channel', () {
    final appcast = parser.parse(_feed, architecture: 'x86_64');
    final items = appcast['items']! as List;

    expect(items, hasLength(1));
    expect(items.single, containsPair('fileURL', 'https://example.com/app-x86_64.AppImage'));
    expect(items.single, containsPair('versionString', '140'));
    expect(items.single, containsPair('displayVersionString', '1.4.0'));
    expect(items.single, containsPair('contentLength', 123));
    expect(items.single, containsPair('operatingSystem', 'linux'));
    expect(items.single, containsPair('architecture', 'x86_64'));
    expect(items.single, containsPair('edSignature', 'signature'));
  });

  test('selects aarch64 independently', () {
    final appcast = parser.parse(_feed, architecture: 'aarch64');
    final items = appcast['items']! as List;

    expect(items, hasLength(1));
    expect(items.single, containsPair('fileURL', 'https://example.com/app-aarch64.AppImage'));
  });

  test('accepts a Linux enclosure without a custom architecture', () {
    final appcast = parser.parse(_feedWithoutArchitecture, architecture: 'x86_64');
    final items = appcast['items']! as List;

    expect(items, hasLength(1));
    expect(items.single, containsPair('versionString', '0.21.2+181'));
    expect(items.single, containsPair('architecture', 'x86_64'));
  });

  test('rejects malformed XML', () {
    expect(() => parser.parse('<rss>', architecture: 'x86_64'), throwsA(isA<XmlTagException>()));
  });
}

const _feed = '''
<?xml version="1.0" encoding="utf-8"?>
<rss
  version="2.0"
  xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"
  xmlns:hippo="https://hippolabs.org/xml-namespaces/auto-updater">
  <channel>
    <item>
      <title>macOS</title>
      <sparkle:version>140</sparkle:version>
      <enclosure
        url="https://example.com/app.zip"
        length="100"
        sparkle:os="macos"
        sparkle:edSignature="signature" />
    </item>
    <item>
      <title>Linux x64</title>
      <sparkle:version>140</sparkle:version>
      <sparkle:shortVersionString>1.4.0</sparkle:shortVersionString>
      <sparkle:releaseNotesLink>https://example.com/notes</sparkle:releaseNotesLink>
      <enclosure
        url="https://example.com/app-x86_64.AppImage"
        length="123"
        type="application/vnd.appimage"
        sparkle:os="linux"
        hippo:arch="x86_64"
        sparkle:edSignature="signature" />
    </item>
    <item>
      <title>Linux ARM64</title>
      <sparkle:version>140</sparkle:version>
      <enclosure
        url="https://example.com/app-aarch64.AppImage"
        length="124"
        type="application/vnd.appimage"
        sparkle:os="linux"
        hippo:arch="aarch64"
        sparkle:edSignature="signature" />
    </item>
    <item>
      <title>Linux beta</title>
      <sparkle:version>150</sparkle:version>
      <sparkle:channel>beta</sparkle:channel>
      <enclosure
        url="https://example.com/app-beta.AppImage"
        length="125"
        sparkle:os="linux"
        hippo:arch="x86_64"
        sparkle:edSignature="signature" />
    </item>
  </channel>
</rss>
''';

const _feedWithoutArchitecture = '''
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <item>
      <sparkle:version>0.21.2+181</sparkle:version>
      <sparkle:shortVersionString>0.21.2</sparkle:shortVersionString>
      <enclosure
        url="https://example.com/app-x86_64.AppImage"
        length="123"
        sparkle:os="linux"
        sparkle:edSignature="signature" />
    </item>
  </channel>
</rss>
''';
