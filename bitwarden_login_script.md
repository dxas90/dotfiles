# Bitwarden Login Script

## Overview
This script automates logging into Bitwarden, supporting both **local** and **remote** vaults. It retrieves the necessary credentials, performs authentication, and unlocks the vault.

## Features
- Supports **local** and **remote** Bitwarden servers.
- Automatically retrieves OTP codes and passwords from a safe location.
- Stores the session key (`BW_SESSION`) to persist login across sessions.
- Cleans up temporary files automatically.

## Usage
Run the script with one of the following arguments:
```sh
./bw-login.sh local    # Login to the local Bitwarden server
./bw-login.sh remote   # Login to the official Bitwarden server
```

After logging in, you can use:
```sh
source ~/.bw_session
```
to persist the session in your shell.

## Configuration
- `SAFE_FOLDER`: Directory where credentials are stored. Default: `$HOME/Vaults/Safe`
- `BW_HOST`: Custom Bitwarden server URL.
- `BW_USER`: Bitwarden username.
- `PASSWORD_FILE`: Custom password file name.

## Troubleshooting
- If login fails, ensure your `.bw.otp.local` or `.bw.otp.remote` file exists.
- Debugging can be enabled by setting `MY_DEBUG=true` or `MY_DEBUG=verbose`.

