: "${WS_NAME:=}"
: "${WS_VERBOSE:=}"
: "${WS_LOG_LEVEL:=}"
: "${WS_CONFIG:=}"
: "${WS_DIR:=}"
: "${WS_REPO_ORIGIN:=}"
: "${WS_VERSION:=}"
: "${WS_VERSION_REPO_FIX:=}"

WS_VERBOSE__default() {
  echo -n "false";
}
WS_LOG_LEVEL__default() {
  echo -n "error";
}
WS_CONFIG__default() {
  printf "%s/.config/workstation" $HOME
}
WS_DIR__default() {
  echo -n "$HOME/.local/share/ws"
}
WS_REPO_ORIGIN__default() {
  echo -n "https://github.com/joelmccracken/ws.git";
}
WS_VERSION__default() {
  echo -n "master";
}

WS_VERSION_REPO_FIX__default() {
  echo -n "refs/remotes/origin/master";
}

export WS_NAME # META:workstation_setting
export WS_VERBOSE # META:workstation_setting
export WS_LOG_LEVEL # META:workstation_setting
export WS_DIR # META:workstation_setting
export WS_CONFIG # META:workstation_setting
export WS_REPO_ORIGIN # META:workstation_setting
export WS_VERSION # META:workstation_setting
export WS_VERSION_REPO_FIX # META:workstation_setting

# logic for looking up values
# there are some complex things we want to do here
# - prevent test runs from accessing user home dir
# - get default values when appropriate
ws_lookup() {
  local name='' val='' bypass_sandbox_check=''

  while (( "$#" > 0 )); do
    case "$1" in
      (--no-test-sandbox) bypass_sandbox_check=true;;
      (*) name="$1";;
    esac
    shift;
  done

  local val="${!name}"

  # are we in a test? if so error if value is home directory
  if [[ -z "$bypass_sandbox_check" ]] && [[ -n "${BATS_TEST_TMPDIR:+x}" ]]; then
    if [[ "$val" == "$BATS_WS_USER_HOME/.config/"* ||
          "$val" == "/etc/"* ]]; then
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
