# Loctree MCP 0.13.0

This repository is the public release mirror for the Loctree MCP server.

The server exposes Loctree structural tools over MCP. This is a release mirror of a private integration monorepo; issues/PRs welcome here.

## Build

```bash
cargo check --workspace
```

## License

BUSL-1.1. See `LICENSE` and `NOTICE.md`.

## Snapshot Notes

- Target repo: `Loctree/loctree-mcp`
- Dependency mode: `crates.io registry`
- Engine crates (loctree, loctree-ast, report-leptos) are consumed from crates.io at the pinned release version; no vendored sources in this mirror.
