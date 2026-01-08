# GitHub Copilot Instructions for `dotfiles`

**Purpose:** Personal configuration files managed with [chezmoi](https://github.com/twpayne/chezmoi). Keep changes minimal, reversible, and shell-first.

## Repository Architecture

**Chezmoi naming conventions** (understand these first):
- `dot_*` → becomes `.filename` in home directory (e.g., `dot_bashrc` → `~/.bashrc`)
- `private_dot_*` → private files with restricted permissions (e.g., `private_dot_ssh/`)
- `executable_*` → files made executable during apply (e.g., `dot_local/bin/executable_nato`)
- `symlink_*` → creates symlinks (e.g., `symlink_dot_face.icon` → `~/.face.icon`)
- `empty_*` → creates empty files (e.g., `empty_dot_hushlogin` → `~/.hushlogin`)
- `readonly_*` → files marked read-only after apply (e.g., `git/readonly_config`)
- `*.tmpl` → go templates processed by chezmoi at apply time
- `run_once_*` → scripts executed once (tracked by chezmoi state)
- `run_onchange_*` → scripts re-run when their content changes
- `run_once_before_*` → run once before main apply (e.g., key decryption)

**External tools** managed via `.chezmoiexternals/extra-tools.toml`:
- Downloads latest releases from GitHub automatically
- Controlled by `external_tools` and `extra_tools` flags in `.chezmoi.toml.tmpl`
- Includes linkerd, argocd, devspace, talosctl, zoxide, task, etc.
- Uses `gitHubLatestReleaseAssetURL` template function for dynamic URLs

**Key directories:**
- `dot_local/bin/` — user executables (9 helper scripts):
  - `executable_custom-bw-login` — Install/login to Bitwarden CLI (`bw`) and `rbw`, handles cross-platform installation
  - `executable_my-ssh-agent` — Start SSH agent with XDG_RUNTIME_DIR socket support
  - `executable_all-kubeconfigs` — Merge multiple kubeconfig files from a directory into KUBECONFIG env var
  - `executable_all-ssh` — Batch add SSH keys to agent (including macOS keychain with `-K`)
  - `executable_lima-install` — Install Lima VM and Colima from latest GitHub releases
  - `executable_nato` — Translate text to NATO phonetic alphabet (Python utility)
  - `executable_oathtool` — Generate TOTP codes (pure Python OATH implementation)
  - `executable_serveit` — Quick HTTP server (tries php, python3, python2, ruby in order)
  - `executable_terminate` — Graceful process termination with escalating signals (15→2→1→9)
- `private_dot_ssh/` — SSH configs using `.tmpl` for dynamic values:
  - `config.tmpl` — global settings, AWS SSM proxy, Tor .onion support, port-knocking
  - `authorized_keys.tmpl` — templated authorized keys
  - `config.d/` — modular SSH config includes
- `dot_config/nvim/` — Neovim with lazy.nvim, structured as `init.lua` + `lua/config/` modules
- `dot_config/systemd/user/` — user systemd units (`ssh-agent.service`, mount units)
- `dot_env-secrets.d/` — modular secret sourcing (sourced by `dot_bashrc`)

## Secret Management System

**Three-tier approach** (critical to understand):

1. **Age encryption** (primary): `key.txt.age` holds encrypted age key, decrypted by `run_once_before_decrypt-private-key.sh.tmpl` to `~/.config/chezmoi/key.txt`
   - Uses Yubikey-based age identity: `age-yubikey-identity-8241d673.txt`
   - Recipient: `age1yubikey1qtdrpsk4ccyge0us58axjv9ncrenm897540r89fm9zzj6d704vdfq2tgtmd`

2. **Password managers** (secret injection):
   - `rbw` (Bitwarden CLI) via `rbwFields` function: `{{ (rbwFields "uuid").FIELD_NAME.value }}`
   - `keepassxc` via `keepassxcAttribute`: `{{ keepassxcAttribute "path" "ATTR_NAME" }}`
   - `keepassxc` entries: `{{ (keepassxc "path").UserName }}`
   - `bw` (official Bitwarden CLI) installed via `.install-password-manager.sh` hook
   - Database location: `~/Sync/chezmoi.kdbx` (KeePassXC)
   - Password manager binaries: Installed to `~/.local/bin/` by bootstrap script

3. **Environment flags** (control secret loading):
   - `SECRETS_OFF=off` — skip secret injection (for clean installs without age key)
   - `SECRETS_AT_HOME=1` — enable homelab-specific secrets (OPNsense, Proxmox)
   - `EXTRA_TOOLS=1` — install additional optional tools
   - Variables set in `.chezmoi.toml.tmpl` and passed to templates

**Example from `dot_env-secrets.tmpl`:**
```go
{{- if .secrets }}
export GITHUB_TOKEN={{ (rbwFields "uuid").FORJEJO_NEW_TOKEN.value }}
{{- end }}
```

**Never commit unencrypted secrets.** Use `private_*` prefix + `.tmpl` templating.

## Developer Workflows

**Bootstrap new system:**
```bash
# Set SECRETS_OFF if no age key exists yet
export SECRETS_OFF="off"
export PATH="$PATH:$HOME/.local/bin"
curl -sS https://starship.rs/install.sh | sh
curl -sS https://raw.githubusercontent.com/dxas90/dotfiles/refs/heads/main/.install-password-manager.sh | bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ${HOME}/.local/bin init --apply dxas90
```

**Test changes locally:**
```bash
chezmoi apply --dry-run --verbose   # Preview changes
chezmoi apply                       # Apply dotfiles
chezmoi diff                        # See what changed
```

**Edit files in source state:**
```bash
chezmoi edit ~/.bashrc              # Opens dot_bashrc in $EDITOR
chezmoi cd                          # Navigate to source directory
```

**After modifying systemd units:**
```bash
systemctl --user daemon-reload
systemctl --user restart ssh-agent.service
```

## Cross-Platform Package Management

**Package installation handled by `run_onchange_install-packages.sh.tmpl`:**
- Detects OS via `{{ .chezmoi.os }}` (darwin, linux)
- Linux: checks kernel release for distro (Ubuntu → apt, Manjaro → yay, WSL → apt, Fedora → dnf)
- macOS: uses Homebrew bundles from `Brewfile` (supports both `brew` and `cask` entries)
- Reads package lists from `.chezmoi.toml.tmpl` data section

**Adding new packages:**
1. Edit `.chezmoi.toml.tmpl`, add to `[data.packages.<platform>.<manager>]` section
   - Example: `packages.darwin.brews = ["curl", "git"]` or `packages.ubuntu.apt = ["curl", "git"]`
   - Supported platforms: `darwin`, `ubuntu`, `arch`, `fedora`, `epam_wsl`
   - Supported managers: `brews`, `casks` (macOS), `apt` (Debian/Ubuntu), `yay` (Arch), `dnf` (Fedora)
2. Change triggers `run_onchange_install-packages.sh.tmpl` re-execution (chezmoi tracks script content hash)

**Tool version management:** Uses `mise.toml` (formerly rtx) for declarative tool versions:
```toml
[tools]
age = "latest"              # Age encryption tool
python = { version='3' }    # Python 3.x latest
sops = "latest"             # Mozilla SOPS for secret management
```
**Mise patterns:**
- Automatically activates on directory change via direnv integration
- Install tools: `mise install` (reads from mise.toml)
- Add new tool: edit `mise.toml`, run `mise install`
- Check versions: `mise current` or `mise ls`
- Global config: `~/.config/mise/config.toml` (not tracked in dotfiles)

## Code Patterns and Conventions

**Shell script structure** (from `dot_local/bin/executable_custom-bw-login`):
```bash
#!/bin/bash
# Optional debug mode
if [ "${MY_DEBUG,,}" == "true" ]; then set -x; fi

set -euo pipefail
IFS=$'\n\t'

# Cleanup pattern
temp_folder=$(mktemp -d -t tmp.XXXXXXXXXX)
trap 'rm -rf "$temp_folder"' EXIT

# Function definitions
function install_tool() { ... }
```

**Neovim structure:** LazyVim-based configuration
- `dot_config/nvim/init.lua` → minimal bootstrap calling `require("config.lazy")`
- `lua/config/` → core configs (autocmds, keymaps, options, lazy plugin manager)
- `lua/plugins/` → plugin-specific overrides (example.lua, luasnip.lua)

**SSH config templating** (from `private_dot_ssh/config.tmpl`):
```go
{{- if (env "XDG_RUNTIME_DIR") }}
  IdentityAgent {{ env "XDG_RUNTIME_DIR" }}/ssh-agent.socket
{{- end }}
```

**SSH advanced features** (from `private_dot_ssh/config.tmpl`):
- **AWS SSM proxy**: `ProxyCommand aws ssm start-session --target %h` for instances matching `i-*` or `mi-*` patterns
- **Tor .onion support**: Routes *.onion hosts through SOCKS5 proxy on `127.0.0.1:9050` using ncat
- **Port knocking**: Pre-connection knock sequence via ProxyCommand for security-hardened hosts
- **Connection multiplexing**: ControlMaster auto with sockets in `~/.ssh/control-sockets/%r-%C`
- **Agent forwarding**: Enabled globally with ForwardAgent yes
- **Colima integration**: Includes `~/.config/colima/ssh_config` for VM access

**Shell initialization chain:**
1. `~/.profile` or `~/.bash_profile` / `~/.zprofile` (login shells)
2. `~/.bashrc` / `~/.zshrc` (interactive shells)
3. Sources `~/.env-secrets` (from `dot_env-secrets.tmpl`)
4. Sources all `~/.env-secrets.d/*.sh` files (modular secret loading)
5. Loads shared aliases from `~/.shell_aliases`
6. Loads shell completions from `~/.shell_completion`

**Chezmoi hooks** (from `.chezmoi.toml.tmpl`):
- `hooks.read-source-state.pre` → runs `.install-password-manager.sh` before reading source (ensures password managers available)
- `hooks.apply.post` → runs `fc-cache -f` after apply (refreshes font cache)

## Helper Script Usage Examples

**Merge multiple kubeconfig files:**
```bash
all-kubeconfigs ~/kubeconfigs/  # Outputs export command
eval $(all-kubeconfigs ~/kubeconfigs/)  # Apply to current shell
```

**Start HTTP server on custom port:**
```bash
serveit 8080  # Defaults to 8000, tries php→python3→python2→ruby
```

**Generate TOTP code:**
```bash
oathtool "BASE32SECRETKEY"  # Outputs 6-digit TOTP code
```

**Translate to NATO phonetic alphabet:**
```bash
nato abc123  # Outputs: Alfa Bravo Charlie One Two Three
```

**Gracefully terminate process:**
```bash
terminate 12345  # Sends SIGTERM, then SIGINT, SIGHUP, finally SIGKILL
```

## Adding New Features

**New helper script:**
```bash
# Create: dot_local/bin/executable_my-helper
#!/bin/bash
set -euo pipefail
# Script logic here
```
PATH already includes `~/.local/bin` via shell configs.

**New templated config:**
```bash
# Create: dot_config/tool/config.tmpl
# Use chezmoi variables:
{{ .chezmoi.hostname }}
{{ .chezmoi.os }}
{{ .chezmoi.arch }}
{{ if .secrets }}...{{ end }}
```

**New systemd user service:**
```ini
# Create: dot_config/systemd/user/myservice.service
[Unit]
Description=My Service

[Service]
ExecStart=/home/daniel/.local/bin/my-script

[Install]
WantedBy=default.target
```

## Critical Constraints

- **Idempotency:** All scripts must be safe to re-run multiple times
- **Cross-platform:** Test on Ubuntu, macOS, consider WSL paths
- **Minimal dependencies:** Prefer coreutils, bash builtins, common tools
- **No hardcoded paths:** Use `$HOME`, chezmoi variables, or `joinPath`
- **Secret safety:** Gate secrets behind `{{ if .secrets }}` checks
**Bootstrap simplicity:** Use `install.sh` for new systems (fetches password manager, then chezmoi)

## Bootstrap Flow (Critical Understanding)

**New system installation sequence:**
1. User runs `install.sh` (or shortlink `sh -c "$(curl -L s.5rv.me/d)" | sh`)
2. Script calls `.install-password-manager.sh` to install `bw` and `rbw`
3. Script installs chezmoi with `--promptDefaults` or `--prompt` flag
4. Chezmoi prompts for feature flags: `secrets`, `secrets_homelab`, `external_tools`, `extra_tools`
5. `run_once_before_decrypt-private-key.sh.tmpl` decrypts age key using Yubikey
6. `run_onchange_install-packages.sh.tmpl` installs packages based on OS
7. Templates process with `rbwFields` for Bitwarden or `keepassxc` for KeePassXC
8. External tools download via `.chezmoiexternals/extra-tools.toml`

**Key bootstrap files:**
- `install.sh` → orchestrates bootstrap (calls password manager installer, then chezmoi)
- `.install-password-manager.sh` → installs bw (Bitwarden CLI) and rbw (alternative)
- `.chezmoi.toml.tmpl` → prompts for feature flags, configures age encryption
- `run_once_before_decrypt-private-key.sh.tmpl` → decrypts age key from Yubikey

## Testing Checklist

Before committing changes:
- [ ] Run `chezmoi apply --dry-run` to verify template syntax
- [ ] Test script with `bash -n script.sh` (syntax check)
- [ ] Verify in clean environment if adding dependencies
- [ ] Check file permissions (private_* files should be 600)
- [ ] Ensure systemd units are syntactically valid (`systemd-analyze verify`)
- [ ] Test bootstrap flow: `export SECRETS_OFF=off && curl -L s.5rv.me/d | sh`

## Reference Files

- `.chezmoi.toml.tmpl` — configuration, package lists, feature flags
- `README.md` — bootstrap instructions, one-liners
- `run_once_before_decrypt-private-key.sh.tmpl` — age key initialization
- `run_onchange_install-packages.sh.tmpl` — cross-platform package installer
- `dot_env-secrets.tmpl` — secret injection patterns
- `private_dot_ssh/config.tmpl` — SSH templating example
- `dot_local/bin/executable_custom-bw-login` — full script pattern with error handling

## Suggestions

- Generate shell functions or scripts for configuration tasks.
- Propose improvements or optimizations to existing scripts.
- Suggest helper functions for repetitive tasks.
- Provide documentation for new functionalities.

## Avoid

- Suggesting complex frameworks or unnecessary dependencies.
- Overly verbose or redundant code.
- Major structural changes without prior discussion.
- Non-shell code or patterns incompatible with the project.

## Notes

- Focus on shell scripting standards.
- Keep solutions simple, correct, and testable.
- Aim for educational value and clarity in all suggestions.
