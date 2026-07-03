# beam_atlas

A standalone Elixir MCP server that exports a target project's dependency,
call, implementation, and runtime relationships as `{edges, dot}`.

## Install as a Claude Code plugin

```
/plugin marketplace add cylkdev/beam_atlas
/plugin install beam-atlas@beam-atlas-plugins
```

On first use the plugin downloads the platform binary from the matching GitHub
release (macOS arm64/x86_64, Linux x86_64); if `beam_atlas` is already on your
PATH it uses that instead. Release binaries are built by
`.github/workflows/release.yml` when a `v*` tag is pushed.

## Install from source

Builds a self-contained [Burrito](https://github.com/burrito-elixir/burrito) binary
and installs it to `/usr/local/bin/beam_atlas` (override with `BIN_DIR`). Requires
Erlang/OTP >= 27, Elixir >= 1.18, and Burrito's build tools (zig, xz, 7z).

```
curl -fsSL https://raw.githubusercontent.com/cylkdev/beam_atlas/main/scripts/remote-install.sh | bash
```

From a checkout of this repo, use `scripts/install.sh` instead (or `scripts/build.sh`
to just build the binaries into `burrito_out/`).

## Run

```
mix deps.get
mix beam_atlas.stdio
```

## Register with Claude Code

```json
{ "mcpServers": {
  "beam_atlas": { "command": "mix", "args": ["beam_atlas.stdio"],
    "cwd": "/absolute/path/to/beam_atlas" } } }
```

## Tools

- `elixir_call_graph` — `project_path`, `query` (E/LC/XC/UC/ME/AE), optional `include_deps`
- `elixir_implementation_graph` — `project_path`, `kind` (behaviours/protocols/both), optional `include_deps`
- `elixir_mix_graph` — `project_path`, `kind` (source_files/compile/export/runtime/compile_connected/dependencies/applications)
- `elixir_runtime_graph` — `node`, `cookie`, `kind` (supervision/links/monitors), optional `roots`

Each tool returns a JSON text block `{"edges": [...], "dot": "..."}`.
