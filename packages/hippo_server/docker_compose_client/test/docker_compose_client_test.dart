import 'package:docker_compose_client/docker_compose_client.dart';
import 'package:test/test.dart';

void main() {
  const project = DockerComposeProject(
    directory: '/srv/hippo/example',
    files: ['compose.yaml', 'compose.production.yaml'],
    projectName: 'example',
    profiles: ['observability'],
    environment: {'IMAGE_TAG': 'v1.2.3'},
    envFiles: ['public.env', '.env.production'],
  );

  test('builds typed pull and up commands without a shell', () async {
    final runner = _FakeRunner();
    final client = DockerComposeClient(processRunner: runner);

    await client.pull(
      project,
      services: ['api'],
      policy: DockerComposePullPolicy.always,
      includeDependencies: true,
    );
    await client.up(
      project,
      services: ['api'],
      forceRecreate: true,
      removeOrphans: true,
      wait: true,
      waitTimeout: const Duration(seconds: 45),
      pull: DockerComposeUpPullPolicy.missing,
    );

    expect(runner.requests.first.executable, 'docker');
    expect(runner.requests.first.workingDirectory, project.directory);
    expect(runner.requests.first.environment, {'IMAGE_TAG': 'v1.2.3'});
    expect(runner.requests.first.arguments, [
      'compose',
      '--project-directory',
      project.directory,
      '--file',
      'compose.yaml',
      '--file',
      'compose.production.yaml',
      '--project-name',
      'example',
      '--profile',
      'observability',
      '--env-file',
      'public.env',
      '--env-file',
      '.env.production',
      'pull',
      '--policy',
      'always',
      '--include-deps',
      'api',
    ]);
    expect(runner.requests.last.arguments, containsAllInOrder(['up', '--detach']));
    expect(runner.requests.last.arguments, containsAllInOrder(['--wait-timeout', '45']));
    expect(runner.requests.last.arguments, containsAllInOrder(['--pull', 'missing', 'api']));
  });

  test('decodes compose ps JSON', () async {
    final runner = _FakeRunner(
      result: const DockerComposeProcessResult(
        exitCode: 0,
        stdout: '''
[
  {"ID":"abc","Name":"example-api-1","Project":"example","Service":"api","State":"running","Health":"healthy","ExitCode":0}
]
''',
        stderr: '',
      ),
    );
    final client = DockerComposeClient(processRunner: runner);

    final services = await client.ps(project);

    expect(services.single.id, 'abc');
    expect(services.single.service, 'api');
    expect(services.single.health, 'healthy');
    expect(services.single.exitCode, 0);
  });

  test('creates bounded log commands', () async {
    final runner = _FakeRunner();
    final client = DockerComposeClient(processRunner: runner);

    await client.logs(
      project,
      services: ['worker'],
      tail: 250,
      since: DateTime.utc(2026, 9, 24, 10),
      timestamps: true,
      timeout: const Duration(seconds: 20),
    );

    final request = runner.requests.single;
    expect(request.arguments, containsAllInOrder(['logs', '--no-color', '--tail', '250']));
    expect(
      request.arguments,
      containsAllInOrder(['--since', '2026-09-24T10:00:00.000Z', '--timestamps', 'worker']),
    );
    expect(request.timeout, const Duration(seconds: 20));
  });

  test('maps non-zero exits to a structured exception', () async {
    final runner = _FakeRunner(
      result: const DockerComposeProcessResult(
        exitCode: 14,
        stdout: '',
        stderr: 'invalid compose project',
      ),
    );
    final client = DockerComposeClient(processRunner: runner);

    await expectLater(
      client.validate(project),
      throwsA(
        isA<DockerComposeException>()
            .having((error) => error.exitCode, 'exitCode', 14)
            .having((error) => error.message, 'message', 'invalid compose project'),
      ),
    );
  });

  test('rejects conflicting recreate options before execution', () {
    final runner = _FakeRunner();
    final client = DockerComposeClient(processRunner: runner);

    expect(() => client.up(project, forceRecreate: true, noRecreate: true), throwsArgumentError);
    expect(runner.requests, isEmpty);
  });

  test('rejects service names that could be parsed as options', () {
    final runner = _FakeRunner();
    final client = DockerComposeClient(processRunner: runner);

    expect(() => client.pull(project, services: ['--ignore-pull-failures']), throwsArgumentError);
    expect(runner.requests, isEmpty);
  });
}

final class _FakeRunner implements DockerComposeProcessRunner {
  _FakeRunner({
    this.result = const DockerComposeProcessResult(exitCode: 0, stdout: '', stderr: ''),
  });

  final DockerComposeProcessResult result;
  final List<DockerComposeProcessRequest> requests = [];

  @override
  Future<DockerComposeProcessResult> run(DockerComposeProcessRequest request) async {
    requests.add(request);
    return result;
  }
}
