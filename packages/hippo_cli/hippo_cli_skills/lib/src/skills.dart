import 'dart:io';

import 'package:hippo_cli_core/hippo_cli_core.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

const defaultHippoSkills = ['hippo-dev', 'emil-design-eng'];

final class SkillsRepoResolver {
  const SkillsRepoResolver({this.environment = const {}});

  final Map<String, String> environment;

  Directory resolve({String? explicitPath, Directory? cwd}) {
    final candidates = <Directory>[
      if (explicitPath != null) Directory(explicitPath),
      if (environment['HIPPOSPHERE_SKILLS_REPO'] case final path?) Directory(path),
      ?cwd,
      Directory.current,
      Directory('/Users/felixweuthen/Projects/Hipposphere/skills'),
    ];
    for (final candidate in candidates) {
      if (isSkillsRepo(candidate)) {
        return candidate.absolute;
      }
    }
    throw const HippoException(
      'Could not find the Hipposphere skills repo.',
      expected: 'Expected a repo with skills/hippo-dev/SKILL.md.',
      nextSteps: ['Pass --repo <path> or set HIPPOSPHERE_SKILLS_REPO.'],
      exitCode: HippoExitCode.config,
    );
  }

  bool isSkillsRepo(Directory directory) {
    return defaultHippoSkills.every(
      (skillName) => File(p.join(directory.path, 'skills', skillName, 'SKILL.md')).existsSync(),
    );
  }
}

final class SkillsTarget {
  const SkillsTarget({required this.name, required this.directory});

  final String name;
  final Directory directory;
}

final class SkillsInstallOptions {
  const SkillsInstallOptions({
    required this.repoRoot,
    required this.targets,
    this.updateRepo = false,
    this.requireUpdate = false,
  });

  final Directory repoRoot;
  final List<SkillsTarget> targets;
  final bool updateRepo;
  final bool requireUpdate;
}

final class SkillsInstaller {
  const SkillsInstaller({
    this.processRunner = const HippoProcessRunner(),
    this.skillNames = defaultHippoSkills,
  });

  final HippoProcessRunner processRunner;
  final List<String> skillNames;

  Future<void> install(SkillsInstallOptions options) async {
    if (options.updateRepo) {
      await updateRepository(options.repoRoot, requireUpdate: options.requireUpdate);
    }
    validateRepo(options.repoRoot);
    for (final target in options.targets) {
      await target.directory.create(recursive: true);
      for (final skillName in skillNames) {
        await _installSymlink(
          source: Directory(p.join(options.repoRoot.path, 'skills', skillName)),
          destination: Link(p.join(target.directory.path, skillName)),
        );
      }
    }
  }

  Future<void> uninstall(SkillsInstallOptions options) async {
    validateRepo(options.repoRoot);
    for (final target in options.targets) {
      for (final skillName in skillNames) {
        await _uninstallSymlink(
          source: Directory(p.join(options.repoRoot.path, 'skills', skillName)),
          destination: Link(p.join(target.directory.path, skillName)),
        );
      }
    }
  }

  Future<void> updateRepository(Directory repoRoot, {required bool requireUpdate}) async {
    if (!Directory(p.join(repoRoot.path, '.git')).existsSync()) {
      if (requireUpdate) {
        throw HippoException(
          'Could not update skills repo.',
          expected: '${repoRoot.path} is not a git repository.',
          exitCode: HippoExitCode.config,
        );
      }
      return;
    }
    final result = await processRunner.run('git', [
      'pull',
      '--ff-only',
    ], workingDirectory: repoRoot.path);
    if (result.exitCode != 0 && requireUpdate) {
      throw HippoException(
        'Could not update skills repo.',
        expected: result.stderr.trim().isEmpty
            ? 'git pull --ff-only failed.'
            : result.stderr.trim(),
        exitCode: HippoExitCode.unavailable,
      );
    }
  }

  void validateRepo(Directory repoRoot) {
    for (final skillName in skillNames) {
      final skillFile = File(p.join(repoRoot.path, 'skills', skillName, 'SKILL.md'));
      if (!skillFile.existsSync()) {
        throw HippoException(
          'Missing skill "$skillName".',
          expected: 'Expected ${skillFile.path}.',
          exitCode: HippoExitCode.config,
        );
      }
    }
  }
}

final class SkillsValidator {
  const SkillsValidator();

  SkillsValidationResult validate(Directory skillDir) {
    final errors = <String>[];
    final skillFile = File(p.join(skillDir.path, 'SKILL.md'));
    if (!skillDir.existsSync()) {
      return const SkillsValidationResult(errors: ['Skill directory does not exist.']);
    }
    if (!skillFile.existsSync()) {
      return const SkillsValidationResult(errors: ['Missing SKILL.md.']);
    }
    final content = skillFile.readAsStringSync();
    final frontmatter = _parseFrontmatter(content, errors);
    final skillName = p.basename(skillDir.path);
    if (frontmatter != null) {
      final name = frontmatter['name'];
      final description = frontmatter['description'];
      if (name is! String || name.trim().isEmpty) {
        errors.add('Frontmatter must include a non-empty string name.');
      } else if (name != skillName) {
        errors.add('Frontmatter name "$name" must match directory "$skillName".');
      }
      if (description is! String || description.trim().isEmpty) {
        errors.add('Frontmatter must include a non-empty string description.');
      }
    }
    if (_bodyAfterFrontmatter(content).trim().isEmpty) {
      errors.add('SKILL.md body must not be empty.');
    }
    for (final referencePath in _referencedLocalPaths(content)) {
      final file = File(p.join(skillDir.path, referencePath));
      final directory = Directory(p.join(skillDir.path, referencePath));
      if (!file.existsSync() && !directory.existsSync()) {
        errors.add('Referenced path does not exist: $referencePath');
      }
    }
    final agentsDir = Directory(p.join(skillDir.path, 'agents'));
    if (agentsDir.existsSync()) {
      for (final entity in agentsDir.listSync(recursive: true, followLinks: false)) {
        if (entity is File && (entity.path.endsWith('.yaml') || entity.path.endsWith('.yml'))) {
          try {
            loadYaml(entity.readAsStringSync());
          } on YamlException catch (error) {
            errors.add(
              'Invalid YAML in ${p.relative(entity.path, from: skillDir.path)}: ${error.message}',
            );
          }
        }
      }
    }
    return SkillsValidationResult(errors: errors);
  }
}

final class SkillsValidationResult {
  const SkillsValidationResult({required this.errors});

  final List<String> errors;
  bool get success => errors.isEmpty;
}

List<Directory> resolveSkillDirs(Directory repoRoot, List<String> skillPaths) {
  if (skillPaths.isEmpty) {
    final root = Directory(p.join(repoRoot.path, 'skills'));
    return root
        .listSync()
        .whereType<Directory>()
        .where((directory) => File(p.join(directory.path, 'SKILL.md')).existsSync())
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }
  return [
    for (final path in skillPaths)
      Directory(
        p.isAbsolute(path)
            ? path
            : path.contains(p.separator)
            ? p.join(repoRoot.path, path)
            : p.join(repoRoot.path, 'skills', path),
      ),
  ];
}

List<SkillsTarget> defaultTargets({
  required Map<String, String> environment,
  required bool codex,
  required bool claude,
}) {
  final home = environment['HOME'] ?? environment['USERPROFILE'];
  if (home == null || home.isEmpty) {
    throw const HippoException('HOME is not set.', exitCode: HippoExitCode.config);
  }
  return [
    if (codex)
      SkillsTarget(
        name: 'Codex',
        directory: Directory(
          environment['CODEX_HOME'] == null
              ? p.join(home, '.codex', 'skills')
              : p.join(environment['CODEX_HOME']!, 'skills'),
        ),
      ),
    if (claude)
      SkillsTarget(name: 'Claude Code', directory: Directory(p.join(home, '.claude', 'skills'))),
  ];
}

Future<void> _installSymlink({required Directory source, required Link destination}) async {
  final destinationType = FileSystemEntity.typeSync(destination.path, followLinks: false);
  if (destinationType != FileSystemEntityType.notFound) {
    if (!await FileSystemEntity.isLink(destination.path)) {
      throw HippoException(
        'Refusing to replace non-symlink path.',
        expected: destination.path,
        exitCode: HippoExitCode.config,
      );
    }
    await destination.delete();
  }
  await destination.create(source.path, recursive: true);
}

Future<void> _uninstallSymlink({required Directory source, required Link destination}) async {
  final destinationType = FileSystemEntity.typeSync(destination.path, followLinks: false);
  if (destinationType == FileSystemEntityType.notFound) {
    return;
  }
  if (!await FileSystemEntity.isLink(destination.path)) {
    throw HippoException(
      'Refusing to remove non-symlink path.',
      expected: destination.path,
      exitCode: HippoExitCode.config,
    );
  }
  final target = await destination.target();
  if (target != source.path) {
    throw HippoException(
      'Refusing to remove symlink with unexpected target.',
      expected: '${destination.path} -> $target',
      exitCode: HippoExitCode.config,
    );
  }
  await destination.delete();
}

YamlMap? _parseFrontmatter(String content, List<String> errors) {
  if (!content.startsWith('---\n')) {
    errors.add('SKILL.md must start with YAML frontmatter.');
    return null;
  }
  final endIndex = content.indexOf('\n---', 4);
  if (endIndex == -1) {
    errors.add('SKILL.md frontmatter must be closed with ---.');
    return null;
  }
  try {
    final document = loadYaml(content.substring(4, endIndex));
    if (document is YamlMap) {
      return document;
    }
    errors.add('SKILL.md frontmatter must be a YAML map.');
  } on YamlException catch (error) {
    errors.add('Invalid SKILL.md frontmatter YAML: ${error.message}');
  }
  return null;
}

String _bodyAfterFrontmatter(String content) {
  if (!content.startsWith('---\n')) {
    return content;
  }
  final endIndex = content.indexOf('\n---', 4);
  return endIndex == -1 ? '' : content.substring(endIndex + '\n---'.length);
}

Set<String> _referencedLocalPaths(String content) {
  final paths = <String>{};
  final pattern = RegExp(r'`((?:agents|assets|references|scripts)/[^`\s]+)`');
  for (final match in pattern.allMatches(content)) {
    if (match.group(1) case final path?) {
      paths.add(path);
    }
  }
  return paths;
}
