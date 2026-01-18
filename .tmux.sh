#!/usr/bin/env bash
set -euo pipefail

TMUX_CONF="$HOME/.tmux.conf"
TMUX_CONF_LOCAL="$HOME/.tmux.conf.local"

URL_MAIN="https://raw.githubusercontent.com/gpakosz/.tmux/refs/heads/master/.tmux.conf"
URL_LOCAL="https://raw.githubusercontent.com/dxas90/dotfiles/refs/heads/main/dot_tmux.conf.local"

# Extract hostname and path for socket-based fallback
get_host_path() {
    local url="$1"
    local host path
    host=$(printf '%s' "$url" | awk -F/ '{print $3}')
    path=$(printf '%s' "$url" | cut -d/ -f4-)
    echo "$host" "$path"
}

# Download using any possible tool
download_file() {
    local url="$1"
    local output="$2"

    echo "Downloading $url -> $output"

    # --- 1) wget ---
    if command -v wget >/dev/null 2>&1; then
        wget -q "$url" -O "$output" && { echo "✔ wget ok"; return 0; }
        echo "wget failed, trying next method..."
    fi

    # --- 2) curl ---
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$output" && { echo "✔ curl ok"; return 0; }
        echo "curl failed, trying next method..."
    fi

    # --- 3) busybox wget ---
    if command -v busybox >/dev/null 2>&1; then
        busybox wget -q "$url" -O "$output" && { echo "✔ busybox wget ok"; return 0; }
        echo "busybox wget failed, trying next method..."
    fi

    # Extract host/path
    read -r host path <<<"$(get_host_path "$url")"

    # --- 4) nc (netcat) ---
    if command -v nc >/dev/null 2>&1; then
        printf "GET /%s HTTP/1.0\r\nHost: %s\r\n\r\n" "$path" "$host" \
            | nc "$host" 80 \
            | sed '1,/^\r$/d' > "$output" 2>/dev/null && { echo "✔ nc ok"; return 0; }
        echo "nc failed, trying next method..."
    fi

    # --- 5) telnet ---
    if command -v telnet >/dev/null 2>&1; then
        {
            sleep 1
            printf "GET /%s HTTP/1.0\r\nHost: %s\r\n\r\n" "$path" "$host"
            sleep 1
        } | telnet "$host" 80 2>/dev/null \
          | sed '1,/^\r$/d' > "$output" && { echo "✔ telnet ok"; return 0; }
        echo "telnet failed, trying next method..."
    fi

    # --- 6) /dev/tcp fallback ---
    if [[ -e /dev/tcp/"$host"/80 ]]; then
        {
            printf "GET /%s HTTP/1.0\r\nHost: %s\r\n\r\n" "$path" "$host"
        } >/dev/tcp/"$host"/80 \
        | sed '1,/^\r$/d' > "$output" 2>/dev/null && { echo "✔ /dev/tcp ok"; return 0; }
        echo "/dev/tcp failed..."
    fi

    echo "❌ ERROR: Could not download file using any available method."
    exit 1
}

# Ensure HOME is writable
if [ ! -w "$HOME" ]; then
    echo "❌ ERROR: Home directory '$HOME' not writable."
    exit 1
fi

# Remove old configs
rm -f "$TMUX_CONF" "$TMUX_CONF_LOCAL"

# Download configs
download_file "$URL_MAIN" "$TMUX_CONF"
download_file "$URL_LOCAL" "$TMUX_CONF_LOCAL"

echo "✔ Done. tmux configuration updated successfully."
