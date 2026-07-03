#!/usr/bin/env bash
#
# Standalone installer for beam_atlas. Safe to run outside the repo, e.g.:
#
#   curl -fsSL https://raw.githubusercontent.com/cylkdev/beam_atlas/main/scripts/remote-install.sh | bash
#
# Downloads the repo, builds the Burrito-wrapped binary for this machine and
# installs it (delegates to scripts/install.sh; BIN_DIR and
# BEAM_ATLAS_INSTALL_DIR are honored the same way).
#
# Requires: git, Erlang/OTP >= MIN_OTP, Elixir >= MIN_ELIXIR, plus Burrito's
# build tools (zig, xz, 7z — checked by scripts/build.sh after cloning).

set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/cylkdev/beam_atlas}"
MIN_ELIXIR="1.18.0"
MIN_OTP="27"

fail() {
  echo "error: $*" >&2
  exit 1
}

# version_gte A B — true if dotted version A >= B
version_gte() {
  [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

# --- Preflight checks -------------------------------------------------------

command -v git >/dev/null || fail "git is required but not installed"
command -v elixir >/dev/null || fail "Elixir is required but not installed (need >= $MIN_ELIXIR)"
command -v erl >/dev/null || fail "Erlang/OTP is required but not installed (need >= $MIN_OTP)"

ELIXIR_VERSION="$(elixir -e 'IO.write(System.version())')"
version_gte "$ELIXIR_VERSION" "$MIN_ELIXIR" ||
  fail "Elixir $ELIXIR_VERSION found, but >= $MIN_ELIXIR is required"

OTP_VERSION="$(erl -noshell -eval 'io:put_chars(erlang:system_info(otp_release)), halt().')"
version_gte "$OTP_VERSION" "$MIN_OTP" ||
  fail "Erlang/OTP $OTP_VERSION found, but >= $MIN_OTP is required"

echo "==> Erlang/OTP $OTP_VERSION and Elixir $ELIXIR_VERSION OK"

# --- Download, build, install -----------------------------------------------

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

echo "==> Cloning $REPO_URL"
git clone --depth 1 "$REPO_URL" "$WORK_DIR/beam_atlas"

# Ensure hex/rebar exist so `mix deps.get` can't hit an interactive prompt
# (stdin may not be a tty under `curl | bash`).
mix local.hex --force --if-missing >/dev/null
mix local.rebar --force >/dev/null

"$WORK_DIR/beam_atlas/scripts/install.sh"
