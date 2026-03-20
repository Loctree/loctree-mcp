# loctree-mcp

Thin release repo for the Loctree MCP server.

This repo is release-only. The implementation lives in `Loctree/Loctree`, and
this repository exists to publish MCP binaries and keep the install channel
clean.

## Role

- receives MCP release assets from the monorepo publish pipeline
- exposes the install surface for `brew install loctree/mcp/loctree-mcp`
- keeps MCP distribution separate from source and docs

## Contents

- release tags
- GitHub release assets
- tap-facing release metadata

