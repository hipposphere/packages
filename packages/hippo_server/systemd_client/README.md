# systemd_client

Typed access to systemd through its D-Bus API, without shelling out to
`systemctl`.

The package supports system and user managers, loaded-unit and unit-file
discovery, unit properties, unit/job/property events, and typed start, stop,
restart, reload, and reload-or-restart operations.

```dart
final client = SystemdClient.system();
final units = await client.listUnits();
final job = await client.restartUnit('dicto.service');
final result = await job.completed;
await client.close();
```

Lifecycle operations may require PolicyKit authorization. Keep authorization
and allowlists in the consuming server; do not expose this client directly to
an untrusted dashboard.
