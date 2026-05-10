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

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/Loctree/loctree-mcp/main/install.sh | bash
```

The installer defaults to `~/.local/bin`, so it does not need `sudo`.
Use `LOCTREE_INSTALL_DIR=/usr/local/bin` only when you intentionally want a
system-wide install and have write access to that directory.

Installed binaries:

- `loct`
- `loctree`
- `loctree-mcp`
- `aicx`
- `aicx-mcp`

The installer verifies SHA256 checksums and verifies detached GPG signatures
when `gpg` is available.

## Releases

### v0.9.5

The `releases/0.9.5/` directory contains signed multi-platform Loctree bundles
that include the `loctree-mcp` binary:

- `aarch64-apple-darwin`
- `aarch64-unknown-linux-gnu`
- `x86_64-unknown-linux-gnu`

Each tarball is tracked with Git LFS and is accompanied by:

- `.sha256` sidecar checksum
- `.sig` detached GPG signature
- `SHA256SUMS` aggregate checksum file
- `manifest.json` release manifest

The public signing key is stored as `loctree-signing.asc`.
