#!/usr/bin/env bash
set -euo pipefail

TMUX_CONF="$HOME/.tmux.conf"
TMUX_CONF_LOCAL="$HOME/.tmux.conf.local"

URL_MAIN="https://raw.githubusercontent.com/gpakosz/.tmux/refs/heads/master/.tmux.conf"
URL_LOCAL="https://raw.githubusercontent.com/dxas90/dotfiles/refs/heads/main/dot_tmux.conf.local"

# Extract hostname and path for socket-based fallback
