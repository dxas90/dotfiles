#!/bin/bash

#If environment variable DEBUG is set to "true" bash debug will be set. Set Debug to "verbose" for more verbose debug information
if [ "${MY_DEBUG,,}" == "true" ]; then set -x; elif [ "${MY_DEBUG,,}" == "verbose" ]; then set -xv; fi

set -euo pipefail
IFS=$'\n\t'
temp_folder=$(mktemp -d -t tmp.XXXXXXXXXX)
cd $temp_folder

function finish {
    rm -rf "$temp_folder"
}

trap finish EXIT

# vim: set syn=sh ts=4 sw=4 et filetype=sh
