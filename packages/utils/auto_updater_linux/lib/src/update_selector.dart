import 'dart:math';

final class LinuxUpdateSelector {
  const LinuxUpdateSelector();

  Map<String, Object?>? select(Map<String, Object?> appcast, {required String installedBuild}) {
    final rawItems = appcast['items'];
    if (rawItems is! List) {
      throw const FormatException('Appcast items are missing.');
    }

    Map<String, Object?>? selected;
    for (final rawItem in rawItems) {
      if (rawItem is! Map) {
        continue;
      }
      final item = Map<String, Object?>.from(rawItem);
      final version = item['versionString'];
      if (version is! String || version.isEmpty) {
        throw const FormatException('A Linux appcast item is missing sparkle:version.');
      }
      final build = _buildFromVersion(version);
      if (compareVersions(build, installedBuild) <= 0) {
        continue;
      }
      if (selected == null ||
          compareVersions(build, _buildFromVersion(selected['versionString']! as String)) > 0) {
        selected = item;
      }
    }
    if (selected != null) {
      _validateUpdateItem(selected);
    }
    return selected;
  }

  int compareVersions(String left, String right) {
    final leftParts = left.split('.');
    final rightParts = right.split('.');
    final length = max(leftParts.length, rightParts.length);
    for (var index = 0; index < length; index += 1) {
      final leftPart = index < leftParts.length ? leftParts[index] : '0';
      final rightPart = index < rightParts.length ? rightParts[index] : '0';
      final leftNumber = BigInt.tryParse(leftPart);
      final rightNumber = BigInt.tryParse(rightPart);
      final comparison = leftNumber != null && rightNumber != null
          ? leftNumber.compareTo(rightNumber)
          : leftPart.compareTo(rightPart);
      if (comparison != 0) {
        return comparison;
      }
    }
    return 0;
  }

  String _buildFromVersion(String version) {
    final separator = version.lastIndexOf('+');
    if (separator < 0 || separator == version.length - 1) {
      return version;
    }
    final build = version.substring(separator + 1);
    return BigInt.tryParse(build) == null ? version : build;
  }

  void _validateUpdateItem(Map<String, Object?> item) {
    final fileUri = Uri.tryParse(item['fileURL'] as String? ?? '');
    if (fileUri == null) {
      throw const FormatException('The AppImage URL is invalid.');
    }
    requireHttps(fileUri, 'AppImage URL');

    final length = item['contentLength'];
    if (length is! int || length <= 0) {
      throw const FormatException('The AppImage enclosure must have a positive length.');
    }
    final signature = item['edSignature'];
    if (signature is! String || signature.isEmpty) {
      throw const FormatException('The AppImage enclosure is missing sparkle:edSignature.');
    }
    final releaseNotes = item['releaseNotesURL'];
    if (releaseNotes is String && releaseNotes.isNotEmpty) {
      final releaseNotesUri = Uri.tryParse(releaseNotes);
      if (releaseNotesUri == null) {
        throw const FormatException('The release notes URL is invalid.');
      }
      requireHttps(releaseNotesUri, 'Release notes URL');
    }
  }

  static void requireHttps(Uri uri, String label) {
    if (uri.scheme != 'https' || uri.host.isEmpty) {
      throw FormatException('$label must be an absolute HTTPS URL.');
    }
  }
}
