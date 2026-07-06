class AppChangelog {
  final List<AppChangelogRelease> releases;

  const AppChangelog({required this.releases});

  static const AppChangelog empty = AppChangelog(releases: []);

  AppChangelogRelease? releaseForVersion(String version) {
    for (final release in releases) {
      if (release.version == version) {
        return release;
      }
    }
    return null;
  }

  List<AppChangelogRelease> releasesFromCurrentVersion({
    required String currentVersion,
    required String? lastSeenVersion,
  }) {
    final currentReleaseIndex = releases.indexWhere(
      (release) => release.version == currentVersion,
    );
    if (currentReleaseIndex == -1) {
      return [];
    }
    if (lastSeenVersion == null) {
      return [releases[currentReleaseIndex]];
    }

    final lastSeenReleaseIndex = releases.indexWhere(
      (release) => release.version == lastSeenVersion,
    );
    if (lastSeenReleaseIndex == -1 ||
        lastSeenReleaseIndex <= currentReleaseIndex) {
      return [releases[currentReleaseIndex]];
    }

    return releases.sublist(currentReleaseIndex, lastSeenReleaseIndex);
  }
}

class AppChangelogRelease {
  final String version;
  final String title;
  final DateTime? releasedAt;
  final List<AppChangelogSection> sections;

  const AppChangelogRelease({
    required this.version,
    required this.title,
    this.releasedAt,
    required this.sections,
  });
}

class AppChangelogSection {
  final String title;
  final List<AppChangelogEntry> entries;

  const AppChangelogSection({required this.title, required this.entries});
}

class AppChangelogEntry {
  final String title;
  final String? description;

  const AppChangelogEntry({required this.title, this.description});
}
