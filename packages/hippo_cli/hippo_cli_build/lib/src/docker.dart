import 'dart:convert';
import 'dart:io';

import 'package:hippo_cli_core/hippo_cli_core.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

final class DockerConfig {
  const DockerConfig({
    required this.source,
    required this.flutterVersion,
    required this.vendor,
    required this.images,
  });

  final String? source;
  final String? flutterVersion;
  final String? vendor;
  final Map<String, DockerImageConfig> images;

  static DockerConfig parse(String yamlText) {
    final document = loadYaml(yamlText);
    if (document is! YamlMap) {
      throw const HippoException(
        'Invalid docker.yaml.',
        expected: 'Expected docker.yaml to contain a YAML map.',
        exitCode: HippoExitCode.config,
      );
    }
    final imagesYaml = document['images'];
    if (imagesYaml is! YamlMap || imagesYaml.isEmpty) {
      throw const HippoException(
        'Invalid docker.yaml.',
        expected: 'Expected an images map.',
        exitCode: HippoExitCode.config,
      );
    }
    return DockerConfig(
      source: _optionalString(document['source']),
      flutterVersion: _optionalString(document['flutter_version']),
      vendor: _optionalString(document['vendor']),
      images: {
        for (final entry in imagesYaml.entries)
          if (entry.key is String)
            entry.key as String: DockerImageConfig.parse(
              entry.key as String,
              entry.value,
              defaultFlutterVersion: _optionalString(document['flutter_version']),
            ),
      },
    );
  }

  Map<String, Object?> toJsonMap() => {
    if (source != null) 'source': source,
    if (flutterVersion != null) 'flutter_version': flutterVersion,
    if (vendor != null) 'vendor': vendor,
    'images': {for (final entry in images.entries) entry.key: entry.value.toJsonMap()},
  };

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJsonMap());
}

final class DockerImageConfig {
  const DockerImageConfig({
    required this.name,
    required this.type,
    required this.package,
    required this.target,
    required this.executable,
    required this.expose,
    required this.title,
    required this.description,
    required this.flutterVersion,
  });

  final String name;
  final String type;
  final String package;
  final String target;
  final String executable;
  final int? expose;
  final String? title;
  final String? description;
  final String? flutterVersion;

  static DockerImageConfig parse(
    String name,
    Object? value, {
    required String? defaultFlutterVersion,
  }) {
    if (value is! YamlMap) {
      throw HippoException(
        'Invalid Docker image "$name".',
        expected: 'Expected image configuration to be a YAML map.',
        exitCode: HippoExitCode.config,
      );
    }
    final type = _requiredString(value, 'type', image: name);
    final package = _requiredString(value, 'package', image: name);
    final target = _optionalString(value['target']) ?? _defaultTarget(type);
    final executable = _optionalString(value['executable']) ?? p.basenameWithoutExtension(target);
    return DockerImageConfig(
      name: name,
      type: type,
      package: package,
      target: target,
      executable: executable,
      expose: _optionalInt(value['expose']),
      title: _optionalString(value['title']),
      description: _optionalString(value['description']),
      flutterVersion: _optionalString(value['flutter_version']) ?? defaultFlutterVersion,
    );
  }

  Map<String, Object?> toJsonMap() => {
    'type': type,
    'package': package,
    'target': target,
    'executable': executable,
    if (expose != null) 'expose': expose,
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (flutterVersion != null) 'flutter_version': flutterVersion,
  };
}

final class DockerGenerateResult {
  const DockerGenerateResult({required this.bakeFile, required this.images});

  final File bakeFile;
  final List<DockerGeneratedImage> images;
}

final class DockerGeneratedImage {
  const DockerGeneratedImage({
    required this.name,
    required this.dockerfile,
    required this.context,
    required this.config,
  });

  final String name;
  final File dockerfile;
  final Directory context;
  final DockerImageConfig config;
}

final class DockerGenerator {
  DockerGenerator({required this.projectRoot});

  final Directory projectRoot;

  Future<DockerConfig> loadConfig({String path = 'docker.yaml'}) async {
    final file = File(p.isAbsolute(path) ? path : p.join(projectRoot.path, path));
    if (!await file.exists()) {
      throw HippoException(
        'Could not find docker.yaml.',
        expected: 'Expected a Docker config at ${file.path}.',
        nextSteps: const ['Create docker.yaml or pass --config <path>.'],
        exitCode: HippoExitCode.config,
      );
    }
    return DockerConfig.parse(await file.readAsString());
  }

  Future<DockerGenerateResult> generate({
    String configPath = 'docker.yaml',
    String? selectedImage,
  }) async {
    final config = await loadConfig(path: configPath);
    final selected = selectedImage == null
        ? config.images.values.toList()
        : [
            config.images[selectedImage] ??
                (throw HippoException(
                  'Unknown Docker image "$selectedImage".',
                  expected: 'Expected one of: ${config.images.keys.join(', ')}.',
                  exitCode: HippoExitCode.usage,
                )),
          ];
    final outputRoot = Directory(p.join(projectRoot.path, '.dart_tool', 'hippo', 'docker'));
    await outputRoot.create(recursive: true);
    final images = <DockerGeneratedImage>[];
    for (final image in selected) {
      final imageRoot = Directory(p.join(outputRoot.path, image.name));
      await imageRoot.create(recursive: true);
      final dockerfile = File(p.join(imageRoot.path, 'Dockerfile'));
      await dockerfile.writeAsString(await _dockerfileFor(config, image));
      images.add(
        DockerGeneratedImage(
          name: image.name,
          dockerfile: dockerfile,
          context: projectRoot,
          config: image,
        ),
      );
    }
    final bakeFile = File(p.join(outputRoot.path, 'docker-bake.hcl'));
    await bakeFile.writeAsString(_bakeFileFor(config.images.values));
    return DockerGenerateResult(bakeFile: bakeFile, images: images);
  }

  Future<int> build({
    required String imageName,
    String configPath = 'docker.yaml',
    bool push = false,
    HippoProcessRunner processRunner = const HippoProcessRunner(),
  }) async {
    final result = await generate(configPath: configPath, selectedImage: imageName);
    final image = result.images.single;
    final command = buildxCommand(image, push: push);
    return processRunner.inherit(
      command.first,
      command.skip(1).toList(),
      workingDirectory: projectRoot.path,
    );
  }
}

List<String> buildxCommand(DockerGeneratedImage image, {required bool push}) {
  return [
    'docker',
    'buildx',
    'build',
    '--file',
    image.dockerfile.path,
    '--tag',
    image.name,
    if (push) '--push' else '--load',
    image.context.path,
  ];
}

Future<String> _dockerfileFor(DockerConfig config, DockerImageConfig image) async {
  return switch (image.type) {
    'flutter_app' => _flutterAppDockerfile(config, image),
    'dart_server' || 'db_migrator' => _dartExecutableDockerfile(config, image),
    _ => throw HippoException(
      'Unsupported Docker image type "${image.type}".',
      expected: 'Expected dart_server, db_migrator, or flutter_app.',
      exitCode: HippoExitCode.config,
    ),
  };
}

String _dartExecutableDockerfile(DockerConfig config, DockerImageConfig image) {
  final flutterVersion = image.flutterVersion ?? 'stable';
  final labels = _labels(config, image);
  return '''
FROM ghcr.io/cirruslabs/flutter:$flutterVersion AS build
WORKDIR /workspace
COPY . .
RUN flutter pub get
RUN dart compile exe ${image.package}/${image.target} -o /app/${image.executable}

FROM debian:trixie-slim
RUN apt-get update \\
    && apt-get install -y --no-install-recommends ca-certificates \\
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
$labels
COPY --from=build /app/${image.executable} /app/${image.executable}
${image.expose == null ? '' : 'EXPOSE ${image.expose}'}
ENTRYPOINT ["/app/${image.executable}"]
''';
}

String _flutterAppDockerfile(DockerConfig config, DockerImageConfig image) {
  final flutterVersion = image.flutterVersion ?? 'stable';
  final labels = _labels(config, image);
  return '''
FROM ghcr.io/cirruslabs/flutter:$flutterVersion AS build
WORKDIR /workspace
COPY . .
RUN flutter pub get
RUN cd ${image.package} && flutter build web --release

FROM nginx:1.29-alpine
$labels
COPY --from=build /workspace/${image.package}/build/web /usr/share/nginx/html
EXPOSE ${image.expose ?? 80}
''';
}

String _labels(DockerConfig config, DockerImageConfig image) {
  final labels = <String, String>{
    if (image.title != null) 'org.opencontainers.image.title': image.title!,
    if (image.description != null) 'org.opencontainers.image.description': image.description!,
    if (config.source != null) 'org.opencontainers.image.source': config.source!,
    if (config.vendor != null) 'org.opencontainers.image.vendor': config.vendor!,
  };
  if (labels.isEmpty) {
    return '';
  }
  return labels.entries
      .map((entry) => 'LABEL ${entry.key}="${entry.value.replaceAll('"', r'\"')}"')
      .join('\n');
}

String _bakeFileFor(Iterable<DockerImageConfig> images) {
  final buffer = StringBuffer();
  buffer.writeln('group "default" {');
  buffer.writeln('  targets = [${images.map((image) => '"${image.name}"').join(', ')}]');
  buffer.writeln('}');
  for (final image in images) {
    buffer
      ..writeln()
      ..writeln('target "${image.name}" {')
      ..writeln('  context = "."')
      ..writeln('  dockerfile = ".dart_tool/hippo/docker/${image.name}/Dockerfile"')
      ..writeln('  tags = ["${image.name}"]')
      ..writeln('}');
  }
  return buffer.toString();
}

String _defaultTarget(String type) => type == 'flutter_app' ? 'lib/main.dart' : 'bin/main.dart';

String _requiredString(YamlMap map, String key, {required String image}) {
  final value = map[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw HippoException(
    'Invalid Docker image "$image".',
    expected: 'Expected "$key" to be a non-empty string.',
    exitCode: HippoExitCode.config,
  );
}

String? _optionalString(Object? value) => value is String && value.isNotEmpty ? value : null;
int? _optionalInt(Object? value) => value is int ? value : int.tryParse(value?.toString() ?? '');
