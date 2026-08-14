import 'package:dbus/dbus.dart';

enum SystemdJobMode {
  replace('replace'),
  fail('fail'),
  isolate('isolate'),
  ignoreDependencies('ignore-dependencies'),
  ignoreRequirements('ignore-requirements');

  const SystemdJobMode(this.value);
  final String value;
}

final class SystemdUnit {
  const SystemdUnit({
    required this.name,
    required this.description,
    required this.loadState,
    required this.activeState,
    required this.subState,
    required this.followedUnit,
    required this.objectPath,
    required this.jobId,
    required this.jobType,
    required this.jobPath,
  });

  final String name;
  final String description;
  final String loadState;
  final String activeState;
  final String subState;
  final String followedUnit;
  final DBusObjectPath objectPath;
  final int jobId;
  final String jobType;
  final DBusObjectPath jobPath;
}

final class SystemdUnitFile {
  const SystemdUnitFile({required this.path, required this.state});
  final String path;
  final String state;
}

final class SystemdUnitDetails {
  const SystemdUnitDetails({
    required this.name,
    required this.objectPath,
    required this.unitProperties,
    required this.typeProperties,
  });

  final String name;
  final DBusObjectPath objectPath;
  final Map<String, Object?> unitProperties;
  final Map<String, Object?> typeProperties;
}

enum SystemdUnitEventType { added, removed }

final class SystemdUnitEvent {
  const SystemdUnitEvent({required this.type, required this.name, required this.objectPath});
  final SystemdUnitEventType type;
  final String name;
  final DBusObjectPath objectPath;
}

final class SystemdJobResult {
  const SystemdJobResult({
    required this.id,
    required this.objectPath,
    required this.unitName,
    required this.result,
  });
  final int id;
  final DBusObjectPath objectPath;
  final String unitName;
  final String result;
  bool get succeeded => result == 'done';
}

final class SystemdJob {
  const SystemdJob({required this.objectPath, required this.unitName, required this.completed});
  final DBusObjectPath objectPath;
  final String unitName;
  final Future<SystemdJobResult> completed;
}

final class SystemdPropertyChange {
  const SystemdPropertyChange({
    required this.objectPath,
    required this.interface,
    required this.changedProperties,
    required this.invalidatedProperties,
  });
  final DBusObjectPath objectPath;
  final String interface;
  final Map<String, Object?> changedProperties;
  final List<String> invalidatedProperties;
}
