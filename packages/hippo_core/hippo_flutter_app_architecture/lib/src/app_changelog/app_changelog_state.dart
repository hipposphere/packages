class AppChangelogState {
  final String? lastSeenVersion;

  const AppChangelogState({required this.lastSeenVersion});

  static const AppChangelogState empty = AppChangelogState(lastSeenVersion: null);

  factory AppChangelogState.fromData(dynamic data) {
    if (data == null) {
      return empty;
    }
    return AppChangelogState(lastSeenVersion: data['last_seen_version']);
  }

  Map<String, dynamic> toData() {
    return {'last_seen_version': lastSeenVersion};
  }
}
