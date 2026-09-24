typedef JsonObject = Map<String, Object?>;

final class DockerComposeProject {
  const DockerComposeProject({
    required this.directory,
    this.files = const ['compose.yaml'],
    this.projectName,
    this.profiles = const [],
    this.environment = const {},
    this.envFiles = const [],
  });

  final String directory;
  final List<String> files;
  final String? projectName;
  final List<String> profiles;
  final Map<String, String> environment;
  final List<String> envFiles;
}

enum DockerComposePullPolicy {
  always('always'),
  missing('missing');

  const DockerComposePullPolicy(this.value);
  final String value;
}

enum DockerComposeUpPullPolicy {
  always('always'),
  missing('missing'),
  never('never');

  const DockerComposeUpPullPolicy(this.value);
  final String value;
}

enum DockerComposeDownImages {
  all('all'),
  local('local');

  const DockerComposeDownImages(this.value);
  final String value;
}

final class DockerComposeCommandResult {
  const DockerComposeCommandResult({
    required this.arguments,
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final List<String> arguments;
  final int exitCode;
  final String stdout;
  final String stderr;
}

final class DockerComposeService {
  const DockerComposeService({
    required this.id,
    required this.name,
    required this.project,
    required this.service,
    required this.state,
    required this.health,
    required this.exitCode,
    required this.raw,
  });

  factory DockerComposeService.fromJson(JsonObject json) => DockerComposeService(
    id: json['ID']?.toString() ?? json['Id']?.toString() ?? '',
    name: json['Name']?.toString() ?? '',
    project: json['Project']?.toString() ?? '',
    service: json['Service']?.toString() ?? '',
    state: json['State']?.toString() ?? '',
    health: json['Health']?.toString(),
    exitCode: _optionalInteger(json['ExitCode']),
    raw: json,
  );

  final String id;
  final String name;
  final String project;
  final String service;
  final String state;
  final String? health;
  final int? exitCode;
  final JsonObject raw;
}

JsonObject jsonObject(Object? value, {String source = 'Docker Compose'}) {
  if (value is! Map) throw FormatException('$source returned a non-object JSON value.');
  return value.map((key, value) => MapEntry(key.toString(), value));
}

int? _optionalInteger(Object? value) => switch (value) {
  int number => number,
  num number => number.toInt(),
  String text => int.tryParse(text),
  _ => null,
};
