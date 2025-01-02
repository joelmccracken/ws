_setup_common() {
  PROJECT_ROOT="$( cd "$(dirname "${BASH_SOURCE[0]}")/../../" &>/dev/null && pwd)"
  BATS_LIB_PATH="$PROJECT_ROOT/test/test_helper:$BATS_LIB_PATH"
  bats_load_library "bats-support"
  bats_load_library "bats-assert"

  export BATS_WS_USER_HOME
  BATS_WS_USER_HOME="$HOME"

  HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
  # need this for a couple of automated commit tests
  git config --global user.email "automated@example.com"
  git config --global user.name "Test Automation"

  ws_unset_settings
  # echo "$PROJECT_ROOT, $BATS_TEST_FILENAME" >&3
  PATH="$PROJECT_ROOT:$PROJECT_ROOT/bin/:$PATH"
  : "${WORKSTATION_DIR:="$PROJECT_ROOT"}"
  . "$PROJECT_ROOT/lib/logging.bash"
  . "$PROJECT_ROOT/lib/lib.bash"
}

set_workstation_version_last_sha() {
  export WORKSTATION_VERSION
  WORKSTATION_VERSION="$(git log -n 1 --format="%H")"
}

retfunc() {
  # use set -o posix
  # plus saving and restoring sets
  # to make set print vars (and not functions)
  local orig_sets
  orig_sets=$(set +o)
  set -o posix
  "$@";
  set | while read -r i; do
      printf "VAR:%s" "$i";
  done
  # declare -p REPLY
  eval "$orig_sets"
}

dump_output() {
    echo "$output" 1>&3
}

ws_get_all_settings() {
   all_settings=()
   while read -r line; do
        if [[ "$line" == export*'META:workstation_setting'* ]]; then
            without_export="${line/#export /}"
            var_name="${without_export/%# META:workstation_setting/}"
            all_settings+=("$var_name")
        fi
   done < "$PROJECT_ROOT/lib/settings.bash"
   read -ra REPLY <<< "${all_settings[@]}"
}

ws_unset_settings() {
    REPLY=()
    ws_get_all_settings
    read -ra all_settings <<< "${REPLY[@]}"
    unset "${all_settings[@]}"
}

ws_reset_settings () {
  ws_unset_settings
  . "$PROJECT_ROOT/lib/settings.bash"
}

tmp (){
  local name="$1"
  local tmp="$BATS_TEST_TMPDIR/$name"
  mkdir -p "$tmp"
  echo "$tmp"
}
