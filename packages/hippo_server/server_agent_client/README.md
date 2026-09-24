# server_agent_client

Typed Dart protocol models and a Unix-socket client for the Hippo Server Agent.

The package communicates with the local agent through
`/run/hippo/agent.sock`. It exposes only the agent's versioned, allow-listed
operations; it does not expose the Docker socket to clients.

```dart
import 'package:server_agent_client/server_agent_client.dart';

final client = ServerAgentClient(socketPath: '/run/hippo/agent.sock');
final status = await client.status();
final containers = await client.listContainers();

await client.execute(
  ServerAgentOperation.restartContainer,
  arguments: {'id': containers.first['Id']},
);
```

Protocol compatibility is represented by `serverAgentProtocolVersion`.
