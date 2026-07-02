# beam_atlas

A standalone Elixir MCP server that exports a target project's dependency,
call, implementation, and runtime relationships as `{edges, dot}`.

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
