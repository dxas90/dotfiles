#!/bin/sh

set -eu

# from https://gist.github.com/dxas90/9f0369536f4eddf2bddfd12e6cdd335b

# Set default PATH
PATH="$PATH${PATH:+:}$HOME/.local/bin"
export PATH

# Decide chezmoi prompt mode (default: --promptDefaults)
PROMPT_FLAG="--promptDefaults"

case "${1:-}" in
  --prompt|-p)
    PROMPT_FLAG="--prompt"
    ;;
  --promptDefaults|"")
    PROMPT_FLAG="--promptDefaults"
    ;;
  *)
    echo "Usage: $0 [--prompt | --promptDefaults]" >&2
    exit 1
    ;;
esac

echo "Applying chezmoi dotfiles with ${PROMPT_FLAG}..."

# Fetch chezmoi installer using curl or wget
if command -v curl >/dev/null 2>&1; then
  FETCH='curl -fsLS'
elif command -v wget >/dev/null 2>&1; then
  FETCH='wget -qO-'
else
  echo "Error: neither curl nor wget is installed" >&2
  exit 1
fi

sh -c "$($FETCH https://raw.githubusercontent.com/dxas90/dotfiles/refs/heads/main/.install-password-manager.sh)"

sh -c "$($FETCH get.chezmoi.io)" -- \
  -b "$HOME/.local/bin" init "$PROMPT_FLAG" --apply dxas90
