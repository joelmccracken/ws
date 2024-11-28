: "${WS_VERBOSE:=false}"
: "${WS_LOG_LEVEL:=error}"
WORKSTATION_NAME_ARG=
WORKSTATION_NAME=

: "${WORKSTATION_CONFIG_DIR:=$HOME/workstation/hosts/current}"
: "${WORKSTATION_SETTINGS_FILE:=${WORKSTATION_CONFIG_DIR}/settings.sh}"

export WORKSTATION_DIR
: "${WORKSTATION_DIR:="$HOME/workstation"}"
export WORKSTATION_EMACS_CONFIG_DIR=~/.config/emacs
export WORKSTATION_GIT_ORIGIN='git@github.com:joelmccracken/workstation.git'
export WORKSTATION_GIT_ORIGIN_PUB='https://github.com/joelmccracken/workstation.git'
export WORKSTATION_HOST_CURRENT_SETTINGS_DIR=$WORKSTATION_DIR/hosts/current
