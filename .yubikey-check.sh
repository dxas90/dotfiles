#!/bin/sh

yubikey_connected() {
    # returns 0 if there is a YubiKey present
    case "$(uname)" in
        Linux)
            lsusb | grep -qi '1050:' || return 1
            ;;
        Darwin)
            ioreg -p IOUSB -l \
                | grep -Eqi 'YubiKey|Yubico' \
                || return 1
            ;;
        *)
            return 1
            ;;
    esac
    return 0
}

if yubikey_connected; then
    echo "🔑  YubiKey present"
    export YUBIKEY_CONNECTED=1
else
    echo "⚠️  No YubiKey detected"
    unset YUBIKEY_CONNECTED
fi

# ex: ts=4 sw=4 et filetype=sh
