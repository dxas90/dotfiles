# dotfiles [![Generic badge](https://img.shields.io/badge/Version-v1.0.0-<COLOR>.svg)](https://shields.io/)

My personal dotfiles managed using [chezmoi](https://github.com/twpayne/chezmoi)

## 🚀 Usage

```console
  sudo apt update ; sudo apt install curl unzip git -y
  # sudo zypper refresh && sudo zypper install -y curl unzip git
  # sudo dnf install -y curl unzip git  # sudo yum install -y curl unzip git
  export SECRETS_OFF="off" # clean install don't have the age key
  export PATH="$PATH${PATH:+:}$HOME/.local/bin" # new binaries path
  curl -sS https://starship.rs/install.sh | sh
  curl https://raw.githubusercontent.com/dxas90/dotfiles/refs/heads/main/.install-password-manager.sh | bash
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ${HOME}/.local/bin init --apply dxas90
```

or

```shell
curl -L https://shorturl.at/PU9Fo | bash # OR
curl -L https://s.5rv.me/dots | bash
```

> this [ssh key](https://github.com/dxas90/dotfiles/blob/main/private_dot_ssh/authorized_keys.tmpl#L1) will have access to the system

## 📝 License

[MIT](https://github.com/dxas90/dotfiles/blob/master/LICENSE)
