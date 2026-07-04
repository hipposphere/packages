# Hippo CLI Concept

`hippo` is the beautiful, batteries-included command line for Hipposphere
development. It should feel like the one trusted front door for day-to-day
workspace work, release automation, Docker artifact generation, agent skill
management, and project diagnostics.

The CLI is implemented in Dart but distributed as native executables, so users
can install and run it on macOS, Linux, and Windows without installing the Dart
SDK.

## Goals

- Provide a single global command: `hippo`.
- Replace direct usage of older helpers such as `dart_edge_ci` and
  `hippo-skills` with grouped `hippo` subcommands.
- Ship native artifacts for Linux, macOS, and Windows.
- Keep CI-friendly behavior deterministic and quiet by default.
- Make local usage polished: colors, icons where terminals support them,
  progress spinners, grouped help, readable tables, and actionable errors.
- Notify users when a newer CLI is available without blocking commands.
- Stay modular so existing Dart Edge CI and skills code can be reused instead
  of copied into a large script.

## Installation

### Native Installer

Recommended installation should download the latest release asset for the host
platform from `https://storage.hippolabs.org/` and place it on `PATH`.

```sh
curl -fsSL https://storage.hippolabs.org/install-hippo-cli.sh | sh
```

Windows:

```powershell
iwr https://hipposphere.dev/install.ps1 -useb | iex
```

The installer should:

- Detect OS and architecture.
- Download the matching signed release asset.
- Verify checksum.
- Install to `~/.hippo/bin/hippo` or `%USERPROFILE%\.hippo\bin\hippo.exe`.
- Add the directory to the shell profile when possible.
- Print the installed version and next command.

### Package Managers

Later distribution targets:

- GitHub Action setup: `uses: hipposphere/setup-hippo@v1`

### Dart Development Install

For contributors:

```sh
dart pub global activate --source path packages/hippo_cli
```

This remains useful for local development, but the primary user path is the
native binary.

## Release Artifacts

Every Hippo CLI release should upload public artifacts to
`https://storage.hippolabs.org/`:

```text
https://storage.hippolabs.org/hippo-cli-<version>-linux-x64.tar.gz
https://storage.hippolabs.org/hippo-cli-<version>-linux-arm64.tar.gz
https://storage.hippolabs.org/hippo-cli-<version>-macos-arm64.tar.gz
https://storage.hippolabs.org/hippo-cli-<version>-windows-x64.zip
```

Each archive should also have a sibling checksum file at the same public path
with `.sha256` appended.

Minimum native targets:

- Linux x64
- Linux arm64
- macOS Apple Silicon
- Windows x64

Each archive contains:

```text
hippo / hippo.exe
LICENSE
README.md
completions/
  hippo.bash
  hippo.fish
  _hippo
```

The release workflow should compile with `dart compile exe`, test the produced
binary with `hippo self version`, generate shell completions, sign or notarize
where needed, publish checksums, and upload everything under the public
`storage.hippolabs.org/hippo-cli-...` path.

The release workflow also publishes the install script and latest-version
metadata:

```text
https://storage.hippolabs.org/install-hippo-cli.sh
https://storage.hippolabs.org/hippo-cli-latest.txt
https://storage.hippolabs.org/hippo-cli-latest.json
```

## Command Shape

```text
hippo
  doctor
  update
  self
    version
    update
    completions
  workspace
    init
    bootstrap
    check
    format
    analyze
    test
  release
    version
    flutter
      build
      publish
      signing
      artifact-paths
      print-config
    docker
      generate
      build
      bake
      print-config
    notes
  test
    routes
    e2e
    env
      up
      down
  bench
    server
  skills
    install
    update
    uninstall
    list
    validate
    doctor
  config
    get
    set
    unset
    path
```

The top-level aliases should be short for common work:

```sh
hippo check
hippo release flutter build ios_app_store
hippo release docker build server --push
hippo skills update
hippo doctor
```

## Migrating Existing Tools

### From `dart_edge_ci`

Existing command:

```sh
dart run dart_edge_ci docker generate
```

New command:

```sh
hippo release docker generate
```

Mapping:

| Old command | New command |
| --- | --- |
| `dart_edge_ci docker generate` | `hippo release docker generate` |
| `dart_edge_ci docker build server` | `hippo release docker build server` |
| `dart_edge_ci docker bake` | `hippo release docker bake` |
| `dart_edge_ci package-version packages/server` | `hippo release version packages/server` |
| `dart_edge_ci flutter build ios_app_store` | `hippo release flutter build ios_app_store` |
| `dart_edge_ci flutter publish ios-app-store` | `hippo release flutter publish ios-app-store` |
| `dart_edge_ci flutter artifact-paths android_play_store` | `hippo release flutter artifact-paths android_play_store` |
| `dart_edge_ci test routes ...` | `hippo test routes ...` |
| `dart_edge_ci test e2e ...` | `hippo test e2e ...` |
| `dart_edge_ci bench server ...` | `hippo bench server ...` |

`dart_edge_ci` can remain as a package-level implementation library and a
compatibility executable while `hippo` becomes the user-facing command.

### From `hippo-skills`

Existing command:

```sh
hippo-skills --update
```

New command:

```sh
hippo skills update
```

Mapping:

| Old command | New command |
| --- | --- |
| `hippo-skills` | `hippo skills install` |
| `hippo-skills --update` | `hippo skills update` |
| `hippo-skills --no-update` | `hippo skills install --no-update` |
| `hippo-skills uninstall` | `hippo skills uninstall` |
| `dart tool/validate.dart` | `hippo skills validate` |

The skills commands should keep support for Codex and Claude targets:

```sh
hippo skills install --codex
hippo skills install --claude
hippo skills uninstall --codex
hippo skills validate hippo-dev
```

## UX Direction

The CLI should look calm, modern, and precise.

### Visual Style

- Use color intentionally: cyan for Hipposphere identity, green for success,
  amber for warnings, red for failures, muted gray for secondary paths.
- Use box drawing only for summaries where it improves scanning.
- Avoid noisy banners in CI or when stdout is not a TTY.
- Prefer concise step labels: `Resolve`, `Build`, `Upload`, `Done`.
- Render tables for artifact paths, packages, skills, and release targets.
- Use progress spinners for network, git, build, and upload steps.
- Use clear fix suggestions for errors.

Example:

```text
Hippo 0.4.0

Workspace  /Users/felix/Projects/Hipposphere/my_app
Mode       release
Config     flutter_release.yaml

Build targets
  ios_app_store       ios       enabled
  android_play_store  android   enabled
  macos_release       macos     enabled

Done in 18.2s
```

### Error Style

```text
Could not find flutter_release.yaml

Expected a Flutter release config in the workspace root.

Next steps:
  hippo release flutter init
  hippo release flutter build --config path/to/flutter_release.yaml ios_app_store
```

### CI Mode

CI should disable spinners, decorative output, update checks, and terminal width
dependent layouts by default.

```sh
hippo release docker generate --ci
```

The CLI should also infer CI mode from common environment variables such as
`CI=true` and `GITHUB_ACTIONS=true`.

## Update Checks

`hippo` should check for updates at most once every 24 hours during interactive
TTY usage. It should never fail the original command if the update check fails.

State lives under:

```text
~/.hippo/state.json
```

Stored values:

```json
{
  "lastUpdateCheck": "2026-06-12T12:00:00Z",
  "latestVersion": "0.5.0",
  "dismissedVersion": null
}
```

Notification style:

```text
Update available: hippo 0.5.0
Run `hippo self update` to upgrade.
```

Rules:

- Skip checks in CI.
- Skip checks when `HIPPO_NO_UPDATE_CHECK=1`.
- Skip checks for commands under `hippo self`.
- Cache storage manifest responses.
- Compare semver versions, including prerelease channels.
- Allow `hippo config set updates.channel stable|beta|nightly`.
- Allow `hippo config set updates.enabled false`.

## Self Update

```sh
hippo self update
hippo self update --version 0.5.0
hippo self update --channel beta
```

Self update should:

- Resolve the current platform artifact.
- Download into a temporary file.
- Verify checksum.
- Replace the current executable atomically where the OS allows it.
- Fall back to printing a manual install command if the executable location is
  not writable.

On Windows, the updater may need a helper process because the running
executable cannot always replace itself.

## Architecture

Recommended package layout:

```text
packages/hippo_cli/
  bin/
    hippo.dart
  lib/
    hippo_cli.dart
    src/
      command_runner.dart
      ui/
        console.dart
        theme.dart
        tables.dart
        progress.dart
      updates/
        update_checker.dart
        self_updater.dart
        release_manifest.dart
      config/
        hippo_config.dart
        state_store.dart
      workspace/
        workspace_detector.dart
      commands/
        hippo_command.dart
        doctor_command.dart
        check_command.dart
        workspace/
          workspace_command.dart
          check_command.dart
        release/
          release_command.dart
          version_command.dart
          docker/
            docker_command.dart
            generate_command.dart
            build_command.dart
        skills/
          skills_command.dart
          install_command.dart
          validate_command.dart
        self/
          self_command.dart
          version_command.dart
```

Implementation boundaries:

- `hippo_cli` owns command names, UX, update checks, config, installers, and
  native packaging.
- `dart_edge_ci` keeps owning Docker generation, Flutter release builds,
  package-version logic, test suite orchestration, and server benchmarks until
  those APIs naturally move to more focused packages.
- The skills repo keeps owning skill content and validation rules, while
  `hippo skills` provides the stable global user experience.

The first version can call existing libraries directly when APIs are public.
Where code only exists behind old executable entry points, move reusable logic
into public library functions first, then let both old and new CLIs call the
same implementation.

## Configuration

Global config:

```text
~/.hippo/config.yaml
```

Workspace config:

```text
.hippo/config.yaml
```

Example:

```yaml
updates:
  enabled: true
  channel: stable

skills:
  repo: /Users/felixweuthen/Projects/Hipposphere/skills
  targets:
    codex: true
    claude: true

release:
  flutter_config: flutter_release.yaml
  docker_config: docker.yaml
```

Precedence:

1. Command flags
2. Environment variables
3. Workspace config
4. Global config
5. Defaults

## Doctor

`hippo doctor` should be the friendly diagnostic center.

Checks:

- Hippo CLI version and update status.
- Current workspace type: package workspace, Dart Edge product, skills repo, or
  unknown.
- Dart SDK availability for source-based development.
- Flutter availability when a Flutter package or release config is present.
- Docker availability when `docker.yaml` exists.
- Git availability and clean/dirty status where commands require it.
- Skills repo availability and installed symlink health.
- GitHub token presence when release commands need API access.

Example:

```text
Hippo doctor

OK   hippo              0.4.0
OK   workspace          Hipposphere package workspace
OK   skills repo        /Users/felix/Projects/Hipposphere/skills
WARN docker             not running
OK   flutter            3.44.2
```

## Release Workflow

The `hippo` binary release should be automated from the package version.

```sh
hippo release version packages/hippo_cli --github-output
```

Release pipeline:

1. Run format, analyze, tests.
2. Compile native binaries.
3. Smoke-test each binary.
4. Generate completions.
5. Archive per platform.
6. Generate checksums.
7. Sign checksums.
8. Upload artifacts to `storage.hippolabs.org`.
9. Print the public download URLs.
10. Publish Homebrew/Scoop/WinGet metadata.

## First Milestone

Deliver a usable `hippo` MVP:

- `hippo --help`
- `hippo doctor`
- `hippo self version`
- `hippo skills install/update/uninstall`
- `hippo release version`
- `hippo release docker generate/build/bake/print-config`
- `hippo release flutter build/artifact-paths/print-config`
- Native artifacts for Linux x64, macOS arm64, and Windows x64
- Update notification checks
- CI-safe output mode

## Later Milestones

- Built-in project scaffolding: `hippo workspace init`.
- Release notes generation from conventional commits and package changelogs.
- GitHub Actions integration: `hippo ci emit`.
- Secret validation for Flutter release signing.
- Full macOS notarization and Windows signing.
- Plugin-style command registration for future Hipposphere packages.
- Machine-readable JSON output for every command that CI might consume.
