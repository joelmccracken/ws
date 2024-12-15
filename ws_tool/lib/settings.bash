WORKSTATION_NAME_ARG=

: "${WORKSTATION_NAME:=}"
: "${WORKSTATION_VERBOSE:=false}"
: "${WORKSTATION_LOG_LEVEL:=error}"
: "${WORKSTATION_CONFIG_DIR:=$HOME/.config/workstation}"
: "${WORKSTATION_CONFIG_FILE:=${WORKSTATION_CONFIG_DIR}/config.sh}"
: "${WORKSTATION_SETTINGS_FILE:=${WORKSTATION_CONFIG_DIR}/settings.sh}"
: "${WORKSTATION_DIR:="$WORKSTATION_CONFIG_DIR/src"}"
: "${WORKSTATION_REPO_GIT_ORIGIN:="https://github.com/joelmccracken/workstation.git"}"
: "${WORKSTATION_VERSION:=master}"
: "${WORKSTATION_INTERACTIVE:=false}"

export WORKSTATION_NAME # META:workstation_setting
export WORKSTATION_VERBOSE # META:workstation_setting
export WORKSTATION_LOG_LEVEL # META:workstation_setting
export WORKSTATION_DIR # META:workstation_setting
export WORKSTATION_CONFIG_DIR # META:workstation_setting
export WORKSTATION_CONFIG_FILE # META:workstation_setting
export WORKSTATION_SETTINGS_FILE # META:workstation_setting
export WORKSTATION_REPO_GIT_ORIGIN # META:workstation_setting
export WORKSTATION_VERSION # META:workstation_setting

# legacy/intermediate versions of these variables
export WORKSTATION_EMACS_CONFIG_DIR=~/.config/emacs
export WORKSTATION_GIT_ORIGIN_PUB='https://github.com/joelmccracken/workstation.git'
export WORKSTATION_HOST_CURRENT_SETTINGS_DIR=$WORKSTATION_DIR/hosts/current
export WORKSTATION_GIT_ORIGIN="git@github.com:joelmccracken/workstation.git"
