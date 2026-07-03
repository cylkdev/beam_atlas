#!/usr/bin/env bash
#
# Install the Burrito-wrapped beam_atlas binary for this machine.
#
# Usage:
#   scripts/install.sh                 # install to /usr/local/bin/beam_atlas
#   BIN_DIR=~/.local/bin scripts/install.sh
#   BEAM_ATLAS_INSTALL_DIR=/opt/beam_atlas scripts/install.sh   # only affects printed config
#
# Builds the host target first if burrito_out/ doesn't have it, then copies
# the binary into BIN_DIR and prints an MCP client config snippet.

set -euo pipefail
cd "$(dirname "$0")/.."

BIN_DIR="${BIN_DIR:-/usr/local/bin}"
INSTALLED="$BIN_DIR/beam_atlas"

case "$(uname -s)-$(uname -m)" in
  Darwin-arm64) TARGET=macos ;;
  Darwin-x86_64) TARGET=macos_intel ;;
  Linux-x86_64) TARGET=linux ;;
  *) echo "error: unsupported host platform $(uname -s)-$(uname -m)" >&2; exit 1 ;;
esac
HOST_BIN="burrito_out/beam_atlas_${TARGET}"

if [[ ! -x "$HOST_BIN" ]]; then
  echo "==> $HOST_BIN not found, building it"
  scripts/build.sh "$TARGET"
fi

echo "==> Installing $HOST_BIN -> $INSTALLED"
mkdir -p "$BIN_DIR" 2>/dev/null || sudo mkdir -p "$BIN_DIR"
if ! install -m 755 "$HOST_BIN" "$INSTALLED" 2>/dev/null; then
  sudo install -m 755 "$HOST_BIN" "$INSTALLED"
fi

echo "==> Installed. MCP client config snippet:"
cat <<EOF
{
  "mcpServers": {
    "beam_atlas": {
      "command": "$INSTALLED"$(
        if [[ -n "${BEAM_ATLAS_INSTALL_DIR:-}" ]]; then
          printf ',\n      "env": { "BEAM_ATLAS_INSTALL_DIR": "%s" }' "$BEAM_ATLAS_INSTALL_DIR"
        fi
      )
    }
  }
}
EOF
