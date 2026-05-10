#!/usr/bin/env bash
set -euo pipefail

REPO="${LOCTREE_RELEASE_REPO:-Loctree/loctree-mcp}"
VERSION="${LOCTREE_VERSION:-0.9.5}"
INSTALL_DIR="${LOCTREE_INSTALL_DIR:-$HOME/.local/bin}"
INSTALL_BINS="${LOCTREE_INSTALL_BINS:-loct loctree loctree-mcp aicx aicx-mcp}"
TMP_DIR=""

cleanup() {
  if [ -n "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
  fi
}

die() {
  printf 'loctree install: %s\n' "$*" >&2
  exit 1
}

need() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

target_triple() {
  local os arch
  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os:$arch" in
    Darwin:arm64) printf 'aarch64-apple-darwin' ;;
    Linux:aarch64|Linux:arm64) printf 'aarch64-unknown-linux-gnu' ;;
    Linux:x86_64|Linux:amd64) printf 'x86_64-unknown-linux-gnu' ;;
    *)
      die "unsupported platform: $os $arch. Available: aarch64-apple-darwin, aarch64-unknown-linux-gnu, x86_64-unknown-linux-gnu"
      ;;
  esac
}

sha256_verify() {
  local file="$1"
  local expected="$2"
  local actual

  if command -v sha256sum >/dev/null 2>&1; then
    actual="$(sha256sum "$file" | awk '{print $1}')"
  elif command -v shasum >/dev/null 2>&1; then
    actual="$(shasum -a 256 "$file" | awk '{print $1}')"
  else
    die "missing sha256 verifier: install sha256sum or shasum"
  fi

  [ "$actual" = "$expected" ] || die "sha256 mismatch for $(basename "$file"): expected $expected, got $actual"
}

gpg_verify_if_available() {
  local file="$1"
  local sig="$2"
  local key="$3"

  if ! command -v gpg >/dev/null 2>&1; then
    printf 'loctree install: gpg not found; detached signature verification skipped (sha256 verified)\n' >&2
    return 0
  fi

  local gpghome
  gpghome="$(mktemp -d)"
  chmod 700 "$gpghome"
  GNUPGHOME="$gpghome" gpg --batch --quiet --import "$key"
  GNUPGHOME="$gpghome" gpg --batch --quiet --trust-model always --verify "$sig" "$file"
  rm -rf "$gpghome"
}

main() {
  need curl
  need tar
  need awk

  local target base_url archive stem tmp expected
  target="$(target_triple)"
  stem="loctree-${VERSION}-${target}"
  archive="${stem}.tar.gz"
  base_url="https://github.com/${REPO}/releases/download/v${VERSION}"
  tmp="$(mktemp -d)"
  TMP_DIR="$tmp"

  trap cleanup EXIT

  printf 'loctree install: version %s, target %s\n' "$VERSION" "$target"
  printf 'loctree install: install dir %s\n' "$INSTALL_DIR"

  curl -fsSL "$base_url/$archive" -o "$tmp/$archive"
  curl -fsSL "$base_url/$archive.sha256" -o "$tmp/$archive.sha256"
  curl -fsSL "$base_url/$archive.sig" -o "$tmp/$archive.sig"
  curl -fsSL "$base_url/loctree-signing.asc" -o "$tmp/loctree-signing.asc"

  expected="$(awk '{print $1}' "$tmp/$archive.sha256")"
  sha256_verify "$tmp/$archive" "$expected"
  gpg_verify_if_available "$tmp/$archive" "$tmp/$archive.sig" "$tmp/loctree-signing.asc"

  tar -xzf "$tmp/$archive" -C "$tmp"
  mkdir -p "$INSTALL_DIR"

  local bin src
  for bin in $INSTALL_BINS; do
    src="$tmp/$stem/bin/$bin"
    [ -x "$src" ] || die "bundle does not contain executable: $bin"
    install -m 755 "$src" "$INSTALL_DIR/$bin"
    printf 'loctree install: installed %s\n' "$INSTALL_DIR/$bin"
  done

  case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *)
      printf '\nloctree install: add this to your shell profile if needed:\n' >&2
      printf '  export PATH="%s:$PATH"\n' "$INSTALL_DIR" >&2
      ;;
  esac

  printf '\nloctree install: done\n'
  for bin in $INSTALL_BINS; do
    "$INSTALL_DIR/$bin" --version 2>/dev/null || true
  done
}

main "$@"
