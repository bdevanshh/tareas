#!/usr/bin/env bash
# Install the host-side tooling used by the Tareas backend (Taskfile runner and
# the golang-migrate CLI). Run from the repo root:
#
#   ./install.sh
#
# Binaries are installed into ~/.local/bin (created if missing). Make sure that
# directory is on your PATH, e.g.:
#   export PATH="$HOME/.local/bin:$PATH"
set -euo pipefail

BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
mkdir -p "$BIN_DIR"

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|amd64) ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

# --- go-task (task) ---------------------------------------------------------
if command -v task >/dev/null 2>&1; then
  echo "task already installed: $(task --version)"
else
  echo "Installing task..."
  curl -sSfL https://taskfile.dev/install.sh | sh -s -- -d -b "$BIN_DIR"
  echo "Installed task to $BIN_DIR"
fi

# --- golang-migrate (migrate) ----------------------------------------------
if command -v migrate >/dev/null 2>&1; then
  echo "migrate already installed: $(migrate -version 2>&1 | head -1)"
else
  echo "Installing golang-migrate..."
  # Resolve the latest release tag.
  TAG="$(curl -sSfL https://api.github.com/repos/golang-migrate/migrate/releases/latest \
        | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4)"
  if [ -z "$TAG" ]; then
    echo "Could not determine latest migrate release" >&2
    exit 1
  fi
  VERSION="${TAG#v}"
  ASSET="migrate.${OS}-${ARCH}.tar.gz"
  URL="https://github.com/golang-migrate/migrate/releases/download/${TAG}/${ASSET}"
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  curl -sSfL "$URL" -o "$TMP/$ASSET"
  tar -xzf "$TMP/$ASSET" -C "$TMP"
  # The archive contains a single 'migrate' binary.
  if [ -f "$TMP/migrate" ]; then
    install -m 0755 "$TMP/migrate" "$BIN_DIR/migrate"
  else
    BIN="$(find "$TMP" -type f -name 'migrate' | head -1)"
    [ -n "$BIN" ] || { echo "migrate binary not found in archive" >&2; exit 1; }
    install -m 0755 "$BIN" "$BIN_DIR/migrate"
  fi
  echo "Installed migrate ${TAG} to $BIN_DIR"
fi

echo
echo "Done. Ensure $BIN_DIR is on your PATH:"
echo "  export PATH=\"$BIN_DIR:\$PATH\""
echo
if ! command -v go >/dev/null 2>&1; then
  echo "NOTE: Go is not installed. The backend requires Go 1.25+ for host development."
  echo "      Install from https://go.dev/dl/ (Docker-based dev does not need it)."
fi