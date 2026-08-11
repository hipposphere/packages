import 'package:xml/xml.dart';

const _sparkleNamespace = 'http://www.andymatuschak.org/xml-namespaces/sparkle';
const _hippoNamespace = 'https://hippolabs.org/xml-namespaces/auto-updater';

final class LinuxAppcastParser {
  const LinuxAppcastParser();

  Map<String, Object?> parse(String source, {required String architecture}) {
    final document = XmlDocument.parse(source);
    final items = <Map<String, Object?>>[];

    for (final element in document.findAllElements('item')) {
      final enclosure = element.findElements('enclosure').firstOrNull;
      if (enclosure == null) {
        continue;
      }

      final operatingSystem = _attribute(enclosure, 'os', namespace: _sparkleNamespace);
      final itemArchitecture = _attribute(enclosure, 'arch', namespace: _hippoNamespace);
      if (operatingSystem != 'linux' ||
          (itemArchitecture != null && itemArchitecture != architecture) ||
          !_isDefaultChannel(element)) {
        continue;
      }

      items.add({
        'versionString': _sparkleText(element, 'version'),
        'displayVersionString': _sparkleText(element, 'shortVersionString'),
        'fileURL': enclosure.getAttribute('url'),
        'contentLength': int.tryParse(enclosure.getAttribute('length') ?? ''),
        'infoURL': _text(element, 'link'),
        'title': _text(element, 'title'),
        'dateString': _text(element, 'pubDate'),
        'releaseNotesURL': _sparkleText(element, 'releaseNotesLink'),
        'itemDescription': _text(element, 'description'),
        'itemDescriptionFormat': _attribute(
          element.findElements('description').firstOrNull,
          'format',
          namespace: _sparkleNamespace,
        ),
        'fullReleaseNotesURL': _sparkleText(element, 'fullReleaseNotesLink'),
        'minimumSystemVersion': _sparkleText(element, 'minimumSystemVersion'),
        'maximumSystemVersion': _sparkleText(element, 'maximumSystemVersion'),
        'channel': _sparkleText(element, 'channel'),
        'operatingSystem': operatingSystem,
        'architecture': itemArchitecture ?? architecture,
        'contentType': enclosure.getAttribute('type'),
        'edSignature': _attribute(enclosure, 'edSignature', namespace: _sparkleNamespace),
      });
    }

    return {'items': items};
  }

  bool _isDefaultChannel(XmlElement item) {
    final channel = _sparkleText(item, 'channel');
    return channel == null || channel.isEmpty;
  }

  String? _sparkleText(XmlElement parent, String localName) {
    final namespaced = parent.findElements(localName, namespaceUri: _sparkleNamespace).firstOrNull;
    if (namespaced != null) {
      return _nonEmpty(namespaced.innerText);
    }
    return null;
  }

  String? _text(XmlElement parent, String localName) {
    return _nonEmpty(parent.findElements(localName).firstOrNull?.innerText);
  }

  String? _attribute(XmlElement? element, String localName, {required String namespace}) {
    return _nonEmpty(element?.getAttribute(localName, namespaceUri: namespace));
  }

  String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
