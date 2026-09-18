#!/usr/bin/env bash
# Installs every language server and formatter this config enables.
# Idempotent: re-running it only installs what is missing.
#
# Deliberately not mason: Claude Code shells out to these same binaries, so they
# must live on the system PATH rather than inside Neovim's data directory.
set -euo pipefail

installed=()
skipped=()

need() {
  if command -v "$1" >/dev/null 2>&1; then
    skipped+=("$1")
    return 1
  fi
  return 0
}

install_with() {
  local bin="$1"
  shift
  if need "$bin"; then
    echo "==> installing $bin"
    "$@"
    installed+=("$bin")
  fi
}

# rustup-managed binaries (rust-analyzer, rustfmt, ...) are all symlinks to the
# `rustup` proxy shim, which exists on PATH as soon as rustup is installed --
# whether or not the component itself is. `command -v` therefore always
# succeeds for them, so need() can never detect a missing component. Ask
# rustup directly instead. Component names in `rustup component list
# --installed` are target-suffixed (e.g. "rust-analyzer-aarch64-apple-darwin"),
# so anchor at the start rather than matching the whole line.
install_rustup_component() {
  local bin="$1" component="$2"
  if rustup component list --installed 2>/dev/null | grep -q "^${component}"; then
    skipped+=("$bin")
  else
    echo "==> installing $bin"
    rustup component add "$component"
    installed+=("$bin")
  fi
}

for required in brew rustup go uv npm; do
  command -v "$required" >/dev/null 2>&1 || {
    echo "error: $required is not installed; cannot continue" >&2
    exit 1
  }
done

# Homebrew
install_with lua-language-server     brew install lua-language-server
install_with bash-language-server    brew install bash-language-server
install_with stylua                  brew install stylua
install_with zls                     brew install zls
install_with tinymist                brew install tinymist

# Rust toolchain
install_rustup_component rust-analyzer rust-analyzer
install_rustup_component rustfmt       rustfmt

# Go toolchain
install_with gopls                   go install golang.org/x/tools/gopls@latest

# gofmt ships with the Go toolchain itself, which is already required as a
# prerequisite above, so there is no install step for it -- scripts/check.lua
# verifies it is on PATH.

# Python, via Astral's uv (same vendor as ruff and ty)
install_with ruff                    uv tool install ruff
install_with ty                      uv tool install ty

# Node
# typescript-language-server@6 rejects typescript@7 ("does not appear to be a
# valid TypeScript installation"), so pin the major below 7. This is not
# staleness -- do not bump it to bare `typescript` without re-checking
# compatibility with whatever ts_ls major is current.
install_with typescript-language-server npm install -g typescript-language-server typescript@5
install_with prettier                npm install -g prettier

echo
echo "installed: ${installed[*]:-none}"
echo "already present: ${skipped[*]:-none}"
echo
echo "If anything is missing from PATH, check that these are on it:"
echo "  \$(go env GOPATH)/bin   \$HOME/.local/bin   \$(brew --prefix)/bin"
