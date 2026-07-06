import 'package:flutter/widgets.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

import 'app_changelog.dart';
import 'app_changelog_state.dart';

enum AppChangelogLaunchPolicy { oncePerVersion, always, never }

class AppChangelogBloc extends BlocBase {
  final AppChangelog changelog;
  final String currentVersion;
  final AppChangelogLaunchPolicy launchPolicy;
  final bool showOnFirstLaunch;
  final StoreController<AppChangelogState> _storeController;

  AppChangelogBloc({
    required KeyValueStore keyValueStore,
    required this.changelog,
    required this.currentVersion,
    this.launchPolicy = AppChangelogLaunchPolicy.oncePerVersion,
    this.showOnFirstLaunch = true,
    AppChangelogState? initialState,
    String storeKey = 'app_changelog',
  }) : _storeController = StoreController<AppChangelogState>(
         keyValueStore: keyValueStore,
         storeKey: storeKey,
         defaultValue: AppChangelogState.empty,
         itemDecoder: (data) => AppChangelogState.fromData(data),
         itemEncoder: (state) => state.toData(),
         initialValue: initialState,
       );

  DataSubject<AppChangelogState?> get stateSubject => _storeController.subject;

  AppChangelogState? get state => stateSubject.value;

  List<AppChangelogRelease> get releasesToShow {
    return changelog.releasesFromCurrentVersion(
      currentVersion: currentVersion,
      lastSeenVersion: state?.lastSeenVersion,
    );
  }

  bool get shouldShowOnLaunch {
    return switch (launchPolicy) {
      AppChangelogLaunchPolicy.never => false,
      AppChangelogLaunchPolicy.always => releasesToShow.isNotEmpty,
      AppChangelogLaunchPolicy.oncePerVersion => _shouldShowOncePerVersion,
    };
  }

  bool get _shouldShowOncePerVersion {
    final currentRelease = changelog.releaseForVersion(currentVersion);
    if (currentRelease == null) {
      return false;
    }

    final lastSeenVersion = state?.lastSeenVersion;
    if (lastSeenVersion == null && !showOnFirstLaunch) {
      return false;
    }

    return lastSeenVersion != currentVersion;
  }

  Future<void> markCurrentVersionSeen() {
    return _storeController.update(
      AppChangelogState(lastSeenVersion: currentVersion),
    );
  }

  Future<void> clearSeenVersion() {
    return _storeController.update(AppChangelogState.empty);
  }

  @override
  void dispose() {
    _storeController.dispose();
  }

  static AppChangelogBloc of(BuildContext context) =>
      BlocProvider.of<AppChangelogBloc>(context);
}
