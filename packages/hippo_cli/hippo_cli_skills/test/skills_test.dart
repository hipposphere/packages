import 'dart:io';

import 'package:hippo_cli_skills/hippo_cli_skills.dart';
import 'package:test/test.dart';

void main() {
  test('validates a skill with frontmatter and body', () async {
    final dir = await Directory.systemTemp.createTemp('hippo_skill_');
    addTearDown(() => dir.delete(recursive: true));
    final skill = Directory('${dir.path}/hippo-dev')..createSync();
    await File('${skill.path}/SKILL.md').writeAsString('''
---
name: hippo-dev
description: Test skill.
---

# Hippo Dev
''');

    final result = const SkillsValidator().validate(skill);

    expect(result.success, isTrue);
  });

  test('installs and uninstalls skill symlinks safely', () async {
    final repo = await Directory.systemTemp.createTemp('hippo_skills_repo_');
    final target = await Directory.systemTemp.createTemp('hippo_skills_target_');
    addTearDown(() => repo.delete(recursive: true));
    addTearDown(() => target.delete(recursive: true));
    for (final skill in defaultHippoSkills) {
      final dir = Directory('${repo.path}/skills/$skill')..createSync(recursive: true);
      await File('${dir.path}/SKILL.md').writeAsString('''
---
name: $skill
description: Test skill.
---

# $skill
''');
    }

    final installer = const SkillsInstaller();
    final options = SkillsInstallOptions(
      repoRoot: repo,
      targets: [SkillsTarget(name: 'Test', directory: target)],
    );

    await installer.install(options);
    expect(await FileSystemEntity.isLink('${target.path}/hippo-dev'), isTrue);

    await installer.uninstall(options);
    expect(
      FileSystemEntity.typeSync('${target.path}/hippo-dev', followLinks: false),
      FileSystemEntityType.notFound,
    );
  });
}
