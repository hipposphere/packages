# Hippo CLI

Command line interface package for Hipposphere tooling.

## Development

Run the CLI from the workspace root:

```sh
dart run packages/hippo_cli/hippo_cli/bin/hippo.dart --help
dart run packages/hippo_cli/hippo_cli/bin/hippo.dart doctor
```

This package owns the executable and command tree. Feature logic lives in
`hippo_cli_core`, `hippo_cli_build`, and `hippo_cli_skills`.
