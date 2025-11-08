# GitHub Copilot Instructions for `dotfiles`

**Purpose:** Personal configuration files managed with [chezmoi](https://github.com/twpayne/chezmoi). Keep changes minimal, reversible, and shell-first.

## Repository Architecture

**Chezmoi naming conventions** (understand these first):
- `dot_*` → becomes `.filename` in home directory (e.g., `dot_bashrc` → `~/.bashrc`)
- `private_dot_*` → private files with restricted permissions (e.g., `private_dot_ssh/`)
- `executable_*` → files made executable during apply (e.g., `dot_local/bin/executable_nato`)
- `*.tmpl` → go templates processed by chezmoi at apply time
- `run_once_*` → scripts executed once (tracked by chezmoi state)
- `run_onchange_*` → scripts re-run when their content changes

**Key directories:**
- `dot_local/bin/` — user executables (9 helper scripts like `executable_custom-bw-login`, `executable_my-ssh-agent`)
- `private_dot_ssh/` — SSH configs using `.tmpl` for dynamic values (see `config.tmpl`, `authorized_keys.tmpl`)
- `dot_config/nvim/` — Neovim with lazy.nvim, structured as `init.lua` + `lua/config/` modules
- `dot_config/systemd/user/` — user systemd units (`ssh-agent.service`, mount units)
- `dot_env-secrets.d/` — modular secret sourcing (sourced by `dot_bashrc`)

## Secret Management System

**Three-tier approach** (critical to understand):

1. **Age encryption** (primary): `key.txt.age` holds encrypted age key, decrypted by `run_once_before_decrypt-private-key.sh.tmpl` to `~/.config/chezmoi/key.txt`

2. **Password managers** (secret injection):
   - `rbw` (Bitwarden CLI) via `rbwFields` function: `{{ (rbwFields "uuid").FIELD_NAME.value }}`
   - `keepassxc` via `keepassxcAttachment`: `{{ keepassxcAttachment "path" "filename" }}`
   - Bitwarden via `bitwardenAttachment`: `{{ bitwardenAttachment "filename" "uuid" }}`

3. **Environment flags** (control secret loading):
   - `SECRETS_OFF=off` — skip secret injection (for clean installs without age key)
   - `SECRETS_AT_HOME=1` — enable homelab-specific secrets
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
curl https://raw.githubusercontent.com/dxas90/dotfiles/refs/heads/main/.install-password-manager.sh | bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ${HOME}/.local/bin init --apply dxas90
```

**Test changes locally:**
```bash
chezmoi apply --dry-run --verbose  # Preview changes
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
- Linux: checks kernel release for distro (Ubuntu → apt, Manjaro → yay, WSL → apt)
- macOS: uses Homebrew bundles from `Brewfile`
- Reads package lists from `.chezmoi.toml.tmpl` data section

**Adding new packages:**
1. Edit `.chezmoi.toml.tmpl`, add to `[data.packages.<platform>.<manager>]`
2. Change triggers `run_onchange_install-packages.sh.tmpl` re-execution

**Tool version management:** Uses `mise.toml` (formerly rtx):
```toml
[tools]
age = "latest"
python = { version='3' }
sops = "latest"
```

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

**Shell initialization chain:**
1. `~/.profile` or `~/.bash_profile` / `~/.zprofile` (login shells)
2. `~/.bashrc` / `~/.zshrc` (interactive shells)
3. Sources `~/.env-secrets` (from `dot_env-secrets.tmpl`)
4. Sources all `~/.env-secrets.d/*.sh`
5. Loads shared aliases from `~/.shell_aliases`

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

## Testing Checklist

Before committing changes:
- [ ] Run `chezmoi apply --dry-run` to verify template syntax
- [ ] Test script with `bash -n script.sh` (syntax check)
- [ ] Verify in clean environment if adding dependencies
- [ ] Check file permissions (private_* files should be 600)
- [ ] Ensure systemd units are syntactically valid (`systemd-analyze verify`)

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
