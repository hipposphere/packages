import 'dart:io';

import 'package:hippo_cli_core/hippo_cli_core.dart';
import 'package:test/test.dart';

void main() {
  test('detects package workspace', () async {
    final dir = await Directory.systemTemp.createTemp('hippo_workspace_');
    addTearDown(() => dir.delete(recursive: true));
    await File('${dir.path}/pubspec.yaml').writeAsString('''
name: hippo_packages_workspace
workspace:
  - packages/*
''');

    final workspace = await const WorkspaceDetector().detect(dir);

    expect(workspace.type, HippoWorkspaceType.packageWorkspace);
  });
}
