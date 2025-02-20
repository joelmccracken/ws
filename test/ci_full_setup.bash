#!/usr/bin/env bash

set -xeuo pipefail

rm -rf $HOME/.config/workstation

unset WS_DIR

bash <(curl "https://raw.githubusercontent.com/joelmccracken/ws/${WS_VERSION}/ws_install.sh")

cd "$HOME/.local/share/ws/"

if [ "$RUNNER_OS" == "macOS" ]; then
    WS_NAME=ci_macos
else
    WS_NAME=ci_ubuntu
fi

./ws bootstrap -n "$WS_NAME" --initial-config-dir ./test/test_config
