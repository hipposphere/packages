import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
import 'package:hippo_flutter_app_architecture/hippo_flutter_app_architecture.dart';

void main() {
  const changelog = AppChangelog(
    releases: [
      AppChangelogRelease(
        version: '1.2.0',
        title: 'Version 1.2.0',
        sections: [
          AppChangelogSection(
            title: 'Dictation',
            entries: [AppChangelogEntry(title: 'Improved dictation startup.')],
          ),
        ],
      ),
      AppChangelogRelease(
        version: '1.1.0',
        title: 'Version 1.1.0',
        sections: [
          AppChangelogSection(
            title: 'Settings',
            entries: [AppChangelogEntry(title: 'Added a compact settings view.')],
          ),
        ],
      ),
      AppChangelogRelease(
        version: '1.0.0',
        title: 'Version 1.0.0',
        sections: [
          AppChangelogSection(
            title: 'General',
            entries: [AppChangelogEntry(title: 'Initial release.')],
          ),
        ],
      ),
    ],
  );

  test('shows the current version on first launch by default', () async {
    final bloc = AppChangelogBloc(
      keyValueStore: MockKeyValueStore(),
      changelog: changelog,
      currentVersion: '1.2.0',
    );
    await Future<void>.delayed(Duration.zero);

    expect(bloc.shouldShowOnLaunch, isTrue);
    expect(bloc.releasesToShow.map((release) => release.version), ['1.2.0']);

    bloc.dispose();
  });

  test('can skip showing changelog on first launch', () async {
    final bloc = AppChangelogBloc(
      keyValueStore: MockKeyValueStore(),
      changelog: changelog,
      currentVersion: '1.2.0',
      showOnFirstLaunch: false,
    );
    await Future<void>.delayed(Duration.zero);

    expect(bloc.shouldShowOnLaunch, isFalse);

    bloc.dispose();
  });

  test('marks the current version as seen', () async {
    final store = MockKeyValueStore();
    final bloc = AppChangelogBloc(
      keyValueStore: store,
      changelog: changelog,
      currentVersion: '1.2.0',
    );
    await Future<void>.delayed(Duration.zero);

    await bloc.markCurrentVersionSeen();

    expect(bloc.shouldShowOnLaunch, isFalse);

    final nextBloc = AppChangelogBloc(
      keyValueStore: store,
      changelog: changelog,
      currentVersion: '1.2.0',
    );
    await Future<void>.delayed(Duration.zero);

    expect(nextBloc.shouldShowOnLaunch, isFalse);

    bloc.dispose();
    nextBloc.dispose();
  });

  test('returns unseen skipped releases newest first', () async {
    final store = MockKeyValueStore();
    final firstBloc = AppChangelogBloc(
      keyValueStore: store,
      changelog: changelog,
      currentVersion: '1.0.0',
    );
    await Future<void>.delayed(Duration.zero);
    await firstBloc.markCurrentVersionSeen();
    firstBloc.dispose();

    final updatedBloc = AppChangelogBloc(
      keyValueStore: store,
      changelog: changelog,
      currentVersion: '1.2.0',
    );
    await Future<void>.delayed(Duration.zero);

    expect(updatedBloc.shouldShowOnLaunch, isTrue);
    expect(updatedBloc.releasesToShow.map((release) => release.version), ['1.2.0', '1.1.0']);

    updatedBloc.dispose();
  });

  test('does not show when the current version has no release notes', () async {
    final bloc = AppChangelogBloc(
      keyValueStore: MockKeyValueStore(),
      changelog: changelog,
      currentVersion: '1.3.0',
    );
    await Future<void>.delayed(Duration.zero);

    expect(bloc.shouldShowOnLaunch, isFalse);
    expect(bloc.releasesToShow, isEmpty);

    bloc.dispose();
  });

  test('always launch policy shows available release notes repeatedly', () async {
    final bloc = AppChangelogBloc(
      keyValueStore: MockKeyValueStore(),
      changelog: changelog,
      currentVersion: '1.2.0',
      launchPolicy: AppChangelogLaunchPolicy.always,
    );
    await Future<void>.delayed(Duration.zero);

    await bloc.markCurrentVersionSeen();

    expect(bloc.shouldShowOnLaunch, isTrue);

    bloc.dispose();
  });
}
