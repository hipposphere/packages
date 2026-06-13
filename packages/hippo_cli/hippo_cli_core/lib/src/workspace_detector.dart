import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

enum HippoWorkspaceType { packageWorkspace, dartEdgeProduct, skillsRepo, package, unknown }

final class HippoWorkspace {
  const HippoWorkspace({required this.root, required this.type, required this.description});

  final Directory root;
  final HippoWorkspaceType type;
  final String description;
}

final class WorkspaceDetector {
  const WorkspaceDetector();

  Future<HippoWorkspace> detect([Directory? start]) async {
    final root = await _findRoot(start ?? Directory.current);
    if (root == null) {
      final current = (start ?? Directory.current).absolute;
      return HippoWorkspace(
        root: current,
        type: HippoWorkspaceType.unknown,
        description: 'unknown workspace',
      );
    }

    if (_isSkillsRepo(root)) {
      return HippoWorkspace(
        root: root,
        type: HippoWorkspaceType.skillsRepo,
        description: 'Hipposphere skills repo',
      );
    }

    final pubspec = File(p.join(root.path, 'pubspec.yaml'));
    final document = await _readYaml(pubspec);
    if (document is YamlMap) {
      if (document['workspace'] is YamlList) {
        final name = document['name'];
        final type = name == 'hippo_packages_workspace'
            ? HippoWorkspaceType.packageWorkspace
            : HippoWorkspaceType.dartEdgeProduct;
        return HippoWorkspace(
          root: root,
          type: type,
          description: type == HippoWorkspaceType.packageWorkspace
              ? 'Hipposphere package workspace'
              : 'Dart workspace',
        );
      }
      return HippoWorkspace(
        root: root,
        type: HippoWorkspaceType.package,
        description: 'Dart package',
      );
    }

    return HippoWorkspace(
      root: root,
      type: HippoWorkspaceType.unknown,
      description: 'unknown workspace',
    );
  }

  Future<Directory?> _findRoot(Directory start) async {
    var current = start.absolute;
    while (true) {
      if (await File(p.join(current.path, 'pubspec.yaml')).exists() || _isSkillsRepo(current)) {
        return current;
      }
      final parent = current.parent;
      if (parent.path == current.path) {
        return null;
      }
      current = parent;
    }
  }

  bool _isSkillsRepo(Directory directory) {
    return File(p.join(directory.path, 'skills', 'hippo-dev', 'SKILL.md')).existsSync();
  }
}

Future<Object?> _readYaml(File file) async {
  if (!await file.exists()) {
    return null;
  }
  return loadYaml(await file.readAsString());
}
