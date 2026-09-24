# docker_compose_client

Typed, shell-free Dart access to Docker Compose project operations. The package
invokes `docker compose` with fixed argument lists and never constructs a shell
command.

```dart
final compose = DockerComposeClient();
const project = DockerComposeProject(
  directory: '/srv/hippo/example',
  files: ['compose.yaml', 'compose.production.yaml'],
);

await compose.validate(project);
await compose.pull(project, policy: DockerComposePullPolicy.always);
await compose.up(project, wait: true, removeOrphans: true);
final services = await compose.ps(project);
```

Callers remain responsible for allowlisting project directories, Compose files,
services, environment values, and operations before accepting remote input.
