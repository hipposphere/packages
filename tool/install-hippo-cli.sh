#!/usr/bin/env sh
set -eu

BASE_URL="${HIPPO_CLI_BASE_URL:-https://storage.hippolabs.org}"
INSTALL_DIR="${HIPPO_CLI_INSTALL_DIR:-$HOME/.local/bin}"
VERSION="${HIPPO_CLI_VERSION:-}"

usage() {
  cat <<'USAGE'
Install the latest Hippo CLI release for this machine.

Usage:
  install-hippo-cli.sh [--version VERSION] [--install-dir DIR]

Environment:
  HIPPO_CLI_VERSION      Install a specific version instead of latest.
  HIPPO_CLI_INSTALL_DIR  Install directory. Defaults to ~/.local/bin.
  HIPPO_CLI_BASE_URL     Artifact base URL. Defaults to storage.hippolabs.org.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --version)
      [ "$#" -ge 2 ] || {
        echo "Missing value for --version." >&2
        exit 1
      }
      VERSION="$2"
      shift 2
      ;;
    --install-dir)
      [ "$#" -ge 2 ] || {
        echo "Missing value for --install-dir." >&2
        exit 1
      }
      INSTALL_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

need_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Required command not found: $1" >&2
    exit 1
  fi
}

download() {
  url="$1"
  output="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$output"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$url" -O "$output"
  else
    echo "Required command not found: curl or wget" >&2
    exit 1
  fi
}

sha256_file() {
  file="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
  else
    echo "Required command not found: shasum or sha256sum" >&2
    exit 1
  fi
}

normalize_arch() {
  case "$(uname -m)" in
    arm64|aarch64)
      echo "arm64"
      ;;
    x86_64|amd64)
      echo "x64"
      ;;
    *)
      echo "Unsupported CPU architecture: $(uname -m)" >&2
      exit 1
      ;;
  esac
}

os="$(uname -s)"
arch="$(normalize_arch)"
executable="hippo"

case "$os" in
  Darwin)
    target_os="macos"
    archive_ext="tar.gz"
    if [ "$arch" != "arm64" ]; then
      echo "Hippo CLI releases currently support macOS arm64 only." >&2
      exit 1
    fi
    ;;
  Linux)
    target_os="linux"
    archive_ext="tar.gz"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    target_os="windows"
    archive_ext="zip"
    executable="hippo.exe"
    if [ "$arch" != "x64" ]; then
      echo "Hippo CLI releases currently support Windows x64 only." >&2
      exit 1
    fi
    ;;
  *)
    echo "Unsupported operating system: $os" >&2
    exit 1
    ;;
esac

if [ -z "$VERSION" ]; then
  latest_file="$(mktemp)"
  download "$BASE_URL/hippo-cli-latest.txt" "$latest_file"
  VERSION="$(tr -d '[:space:]' < "$latest_file")"
  rm -f "$latest_file"
fi

if [ -z "$VERSION" ]; then
  echo "Could not resolve latest Hippo CLI version." >&2
  exit 1
fi

archive="hippo-cli-$VERSION-$target_os-$arch.$archive_ext"
archive_url="$BASE_URL/$archive"
checksum_url="$archive_url.sha256"
work_dir="$(mktemp -d)"

cleanup() {
  rm -rf "$work_dir"
}
trap cleanup EXIT INT TERM

archive_path="$work_dir/$archive"
checksum_path="$work_dir/$archive.sha256"
package_dir="$work_dir/package"

echo "Installing Hippo CLI $VERSION for $target_os-$arch..."
download "$archive_url" "$archive_path"
download "$checksum_url" "$checksum_path"

expected_hash="$(awk '{print $1}' "$checksum_path")"
actual_hash="$(sha256_file "$archive_path")"

if [ "$expected_hash" != "$actual_hash" ]; then
  echo "Checksum verification failed for $archive." >&2
  echo "Expected: $expected_hash" >&2
  echo "Actual:   $actual_hash" >&2
  exit 1
fi

mkdir -p "$package_dir"
case "$archive_ext" in
  tar.gz)
    need_command tar
    tar -xzf "$archive_path" -C "$package_dir"
    ;;
  zip)
    need_command unzip
    unzip -q "$archive_path" -d "$package_dir"
    ;;
esac

if [ ! -f "$package_dir/$executable" ]; then
  echo "Archive did not contain $executable." >&2
  exit 1
fi

mkdir -p "$INSTALL_DIR"
install -m 755 "$package_dir/$executable" "$INSTALL_DIR/$executable"

echo "Installed $INSTALL_DIR/$executable"
case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *)
    echo "Add $INSTALL_DIR to PATH to run hippo from any shell."
    ;;
esac
