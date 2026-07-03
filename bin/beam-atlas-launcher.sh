#!/usr/bin/env bash
#
# Claude Code plugin launcher for beam_atlas.
#
# On first run, downloads the platform-appropriate Burrito binary from the
# GitHub release matching RELEASE_TAG into a persistent data dir, then execs
# it (the binary IS the stdio MCP server). Subsequent runs exec the cached
# binary directly. If a `beam_atlas` is already on PATH (e.g. installed via
# scripts/install.sh), that is preferred and nothing is downloaded.
#
# RELEASE_TAG is bumped together with the plugin version in
# .claude-plugin/plugin.json; changing it triggers a fresh download.

set -euo pipefail

RELEASE_TAG="v0.1.0"
REPO="cylkdev/beam_atlas"

# Prefer a system-wide install if present.
if command -v beam_atlas >/dev/null 2>&1; then
  exec beam_atlas "$@"
fi

case "$(uname -s)-$(uname -m)" in
  Darwin-arm64)  ASSET="beam_atlas_macos" ;;
  Darwin-x86_64) ASSET="beam_atlas_macos_intel" ;;
  Linux-x86_64)  ASSET="beam_atlas_linux" ;;
  *)
    echo "beam-atlas: unsupported platform $(uname -s)-$(uname -m); install manually via https://github.com/$REPO" >&2
    exit 1
    ;;
esac

DATA_DIR="${BEAM_ATLAS_DATA_DIR:-$HOME/.local/share/beam_atlas}"
BIN="$DATA_DIR/$RELEASE_TAG/$ASSET"

if [[ ! -x "$BIN" ]]; then
  URL="https://github.com/$REPO/releases/download/$RELEASE_TAG/$ASSET"
  mkdir -p "$(dirname "$BIN")"
  # Log to stderr only — stdout belongs to the MCP stdio protocol.
  echo "beam-atlas: downloading $URL" >&2
  curl -fsSL --retry 3 -o "$BIN.tmp" "$URL"
  chmod +x "$BIN.tmp"
  mv "$BIN.tmp" "$BIN"
fi

exec "$BIN" "$@"
