#!/usr/bin/env bash
#
# Build Burrito-wrapped release binaries into burrito_out/.
#
# Usage:
#   scripts/build.sh            # build all targets (macos, macos_intel, linux, windows)
#   scripts/build.sh macos      # build a single target
#
# Burrito caches the unpacked payload per app version (e.g. under
# ~/Library/Application Support/.burrito on macOS). Rebuilding at the same
# version would keep running the stale payload, so before building we ask the
# existing host binary to uninstall its cached payload.

set -euo pipefail
cd "$(dirname "$0")/.."

TARGET="${1:-}"

for tool in zig xz 7z; do
  command -v "$tool" >/dev/null || {
    echo "error: $tool is required by Burrito but not installed (macOS: brew install zig xz p7zip)" >&2
    exit 1
  }
done

# Which burrito_out binary can run on this machine (used for cache cleanup).
case "$(uname -s)-$(uname -m)" in
  Darwin-arm64) HOST_BIN=burrito_out/beam_atlas_macos ;;
  Darwin-x86_64) HOST_BIN=burrito_out/beam_atlas_macos_intel ;;
  Linux-x86_64) HOST_BIN=burrito_out/beam_atlas_linux ;;
  *) HOST_BIN="" ;;
esac

if [[ -n "$HOST_BIN" && -x "$HOST_BIN" ]]; then
  echo "==> Uninstalling cached Burrito payload (avoids stale-payload gotcha)"
  "$HOST_BIN" maintenance uninstall <<< "y" || true
fi

echo "==> Fetching deps and building release"
mix deps.get
if [[ -n "$TARGET" ]]; then
  BURRITO_TARGET="$TARGET" MIX_ENV=prod mix release --overwrite
else
  MIX_ENV=prod mix release --overwrite
fi

echo "==> Binaries:"
ls -lh burrito_out/
