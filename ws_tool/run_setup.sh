#!/usr/bin/env sh


rm -rf $HOME/.config/workstation

unset WORKSTATION_DIR
export WORKSTATION_NAME=angrist
export WORKSTATION_VERSION=workcomp

bash ws_install.sh

~/.config/workstation/workstation_source/ws_tool/ws bootstrap
