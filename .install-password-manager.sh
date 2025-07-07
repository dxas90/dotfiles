#!/bin/bash

USER_BIN_DIR="${HOME:-/home/daniel}/.local/bin"
OS_TYPE="$(uname -s)"

set -euo pipefail
IFS=$'\n\t'
temp_folder=$(mktemp -d -t tmp.XXXXXXXXXX)
cd $temp_folder

function finish {
    rm -rf "$temp_folder"
}

trap finish EXIT

function install_password_manager_linux() {
  type bw >/dev/null 2>&1 && exit
  mkdir -p "${USER_BIN_DIR}"
  curl -sL "https://github.com/bitwarden/clients/releases/download/cli-v2025.6.1/bw-linux-2025.6.1.zip" | funzip > bw
  install -m 0755 bw "${USER_BIN_DIR}/bw"
}

function install_password_manager_macos() {
  type bw >/dev/null 2>&1 && exit
  mkdir -p "${USER_BIN_DIR}"
  curl -sL "https://github.com/bitwarden/clients/releases/download/cli-v2025.6.1/bw-macos-2025.6.1.zip" | funzip > bw
  install -m 0755 bw "${USER_BIN_DIR}/bw"
}

function install_password_manager_backup_linux() {
  type rbw >/dev/null 2>&1 && exit
  mkdir -p "${USER_BIN_DIR}"
  curl -sLo rbw.tar.gz "https://github.com/doy/rbw/releases/download/1.13.2/rbw_1.13.2_linux_amd64.tar.gz"
  tar xzf rbw.tar.gz
  install -m 0755 rbw "${USER_BIN_DIR}/rbw"
  install -m 0755 rbw-agent "${USER_BIN_DIR}/rbw-agent"
}

function install_or_update_rust() {
  source "$HOME/.cargo/env" || true
  if command -v rustup >/dev/null 2>&1; then
    echo "Rust is already installed. Updating..."
    rustup self update
    rustup update
  else
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
  fi
}

function install_password_manager_backup_macos() {
  type rbw >/dev/null 2>&1 && return
  mkdir -p "${USER_BIN_DIR}"
  git clone --depth=1 https://github.com/doy/rbw.git
  cd rbw
  cargo build --release
  install -m 0755 target/release/rbw "${USER_BIN_DIR}/rbw"
  install -m 0755 target/release/rbw-agent "${USER_BIN_DIR}/rbw-agent"
}

if [[ "$OS_TYPE" == "Linux" ]]; then
  echo "Detected Linux OS"
  install_password_manager_linux
  install_password_manager_backup_linux
elif [[ "$OS_TYPE" == "Darwin" ]]; then
  echo "Detected macOS"
  install_or_update_rust
  install_password_manager_macos
  install_password_manager_backup_macos
else
  echo "Unsupported OS: $OS_TYPE"
  exit 1
fi
