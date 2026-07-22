#!/usr/bin/env sh
set -eu

echo "The Hippo CLI installer has moved to hipposphere/hippo-cli." >&2

if command -v curl >/dev/null 2>&1; then
  exec curl -fsSL https://raw.githubusercontent.com/hipposphere/hippo-cli/main/tool/install-hippo-cli.sh | sh -s -- "$@"
fi

if command -v wget >/dev/null 2>&1; then
  exec wget -qO- https://raw.githubusercontent.com/hipposphere/hippo-cli/main/tool/install-hippo-cli.sh | sh -s -- "$@"
fi

echo "Required command not found: curl or wget" >&2
exit 1
