# hippo_test_server

Reusable real server fixtures, layered on `hippo_test_core`. Product-specific server composition, accounts, domain data and assertions remain in the product repository.

- `serverTest`: named plain Dart scenarios with the shared evidence format.
- `TestServerProcess`: starts a subprocess, captures logs, requires a loopback readiness message, and closes it through stdin (`stop`) with bounded shutdown.
- `TestPostgres`: provisions a private cluster using installed `initdb` and `postgres`, a temporary data directory, a dynamic loopback port, and real server migrations. It never uses a developer database. Trust authentication is limited to the private test cluster; there is no public listener. Supply `binDirectory` when binaries are not on PATH.
- `ClientNetworkLink`: forwards actual TCP traffic (including HTTP and WebSockets). Offline closes established connections and rejects new ones for that client; other client links remain online. Counters distinguish disconnects from rejected connection attempts.
- `LoopbackHttpOverrides`: allows actual HTTP in widget tests while rejecting external destinations. It does not mock server responses or application transport.

```dart
final resources = TestResources();
final server = await TestServerProcess.start(
  executable: dartExecutable,
  arguments: ['run', 'tool/journey_server.dart'],
  workingDirectory: productRoot,
  resources: resources,
  recorder: scenario,
);
final a = await ClientNetworkLink.open(server.baseUri);
resources.onCleanup(a.close);
a.setOffline(true);
```

The product entry point prints `{"hippo_test_ready":"http://127.0.0.1:PORT"}` after its actual server is listening and migrations finish. It must close resources when stdin receives `stop` or EOF. Test code supplies its executable; this package does not assume a project layout, Docker, credentials, or an SDK installation path.

Run plain Dart suites with `dart run hippo_test_server test`. Inspect them in the same Jaspr viewer as app journeys. Native-backed product servers must be launched using the product's normal Dart command so build hooks and native assets are available.
