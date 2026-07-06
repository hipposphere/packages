import 'package:flutter/widgets.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

import 'app_changelog_bloc.dart';
import 'app_changelog_state.dart';

class AppChangelogBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, AppChangelogState? state) builder;

  const AppChangelogBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final bloc = AppChangelogBloc.of(context);
    return DataSubjectBuilder(subject: bloc.stateSubject, builder: builder);
  }
}

/// This is an unsafe version of [AppChangelogBuilder] that does not provide
/// type safety for the [AppChangelogState] object.
class AppChangelogUnsafeBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, AppChangelogState state) builder;

  const AppChangelogUnsafeBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final bloc = AppChangelogBloc.of(context);
    return DataSubjectBuilder(
      subject: bloc.stateSubject,
      builder: (context, state) => builder(context, state!),
    );
  }
}
