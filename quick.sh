#!/bin/sh

set -eu
curl https://mise.run | sh

$HOME/.local/bin/mise use -g awscli@2 bat croc eza fd fzf gh glab go@1 jq node@24 ripgrep yq zoxide
