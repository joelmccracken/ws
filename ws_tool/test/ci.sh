#!/usr/bin/env sh

set -xeuo pipefail

rm -rf $HOME/.config/workstation

unset WORKSTATION_DIR
export WORKSTATION_VERSION="$GITHUB_SHA"

bash ws_install.sh

~/.config/workstation/workstation_source/ws_tool/ws bootstrap -n angrist --initial-config-dir ./my_config



if [ "$RUNNER_OS" == "macOS" ]; then
    bash bootstrap-workstation.sh ci-macos $WORKSTATION_BOOTSTRAP_COMMIT
else
    bash bootstrap-workstation.sh ci-ubuntu $WORKSTATION_BOOTSTRAP_COMMIT
fi
