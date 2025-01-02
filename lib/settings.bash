ws_config_dir_default () {
  printf "%s/.config/workstation" $HOME
}

ws_config_src_default () {
  printf "%s/.config/workstation/" $HOME
}

: "${WORKSTATION_NAME:=}"
: "${WORKSTATION_VERBOSE:=false}"
: "${WORKSTATION_LOG_LEVEL:=error}"
: "${WORKSTATION_CONFIG_DIR:="$(ws_config_dir_default)"}"
: "${WORKSTATION_DIR:="$WORKSTATION_CONFIG_DIR/vendor/ws"}"
: "${WORKSTATION_REPO_GIT_ORIGIN:="https://github.com/joelmccracken/ws.git"}"
: "${WORKSTATION_VERSION:=master}"

export WORKSTATION_NAME # META:workstation_setting
export WORKSTATION_VERBOSE # META:workstation_setting
export WORKSTATION_LOG_LEVEL # META:workstation_setting
export WORKSTATION_DIR # META:workstation_setting
export WORKSTATION_CONFIG_DIR # META:workstation_setting
export WORKSTATION_REPO_GIT_ORIGIN # META:workstation_setting
export WORKSTATION_VERSION # META:workstation_setting

# legacy/intermediate versions of these variables
export WORKSTATION_EMACS_CONFIG_DIR=~/.config/emacs
export WORKSTATION_GIT_ORIGIN_PUB='https://github.com/joelmccracken/ws.git'
export WORKSTATION_HOST_CURRENT_SETTINGS_DIR=$WORKSTATION_DIR/hosts/current
export WORKSTATION_GIT_ORIGIN="git@github.com:joelmccracken/ws.git"


# WS_USER_DIR=
# WS_SRC_DIR=

# logic for looking up values
# there are some complex things we want to do here
# - prevent test runs from accessing user home dir
# - get default values when appropriate

ws_lookup() {
  local name val bypass_sandbox_check

  while (( "$#" > 0 )); do
    case "$1" in
      (--no-test-sandbox) bypass_sandbox_check=true;;
      (*) name="$1";;
    esac
    shift;
  done

  local val="${!name}"

  # are we in a test? if so error if value is home directory
  if [[ -z "$bypass_sandbox_check" ]] && [[ -n "$BATS_TEST_TMPDIR" ]]; then
    if [[ "$val" == "$BATS_WS_USER_HOME/.config/"* ]]; then
      echo "error: test isolation violation: '$name' has value '$val'"
      exit 1;
    fi
  fi

  # TODO maybe sometimes getting defaults on empty is bad?
  if [[ -z "$val" ]]; then
    if type "${name}__default" > /dev/null; then
      local new_val
      new_val=$(${name}__default)
      eval "$name='$new_val'"
    fi
  fi
  # lookup again as it may have changed during reset
  echo "${!name}"
}
