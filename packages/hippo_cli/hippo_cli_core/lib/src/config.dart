import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

final class HippoConfig {
  const HippoConfig({this.global = const {}, this.workspace = const {}});

  final Map<String, Object?> global;
  final Map<String, Object?> workspace;

  static Future<HippoConfig> load({
    required Directory cwd,
    Map<String, String>? environment,
  }) async {
    final env = environment ?? Platform.environment;
    final home = env['HOME'] ?? env['USERPROFILE'];
    final globalFile = home == null ? null : File(p.join(home, '.hippo', 'config.yaml'));
    final workspaceFile = File(p.join(cwd.path, '.hippo', 'config.yaml'));
    return HippoConfig(
      global: globalFile == null ? const {} : await _readYamlMap(globalFile),
      workspace: await _readYamlMap(workspaceFile),
    );
  }

  Object? getPath(List<String> path) {
    final workspaceValue = _lookup(workspace, path);
    if (workspaceValue != null) {
      return workspaceValue;
    }
    return _lookup(global, path);
  }
}

Future<Map<String, Object?>> _readYamlMap(File file) async {
  if (!await file.exists()) {
    return const {};
  }
  final document = loadYaml(await file.readAsString());
  if (document is! YamlMap) {
    return const {};
  }
  return _toPlainMap(document);
}

Object? _lookup(Map<String, Object?> map, List<String> path) {
  Object? current = map;
  for (final segment in path) {
    if (current is! Map<String, Object?> || !current.containsKey(segment)) {
      return null;
    }
    current = current[segment];
  }
  return current;
}

Map<String, Object?> _toPlainMap(YamlMap yaml) {
  return {
    for (final entry in yaml.entries)
      if (entry.key is String) entry.key as String: _toPlainValue(entry.value),
  };
}

Object? _toPlainValue(Object? value) {
  if (value is YamlMap) {
    return _toPlainMap(value);
  }
  if (value is YamlList) {
    return [for (final item in value) _toPlainValue(item)];
  }
  return value;
}
