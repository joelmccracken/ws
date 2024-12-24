#!/usr/bin/env bash

_setup_common() {
   # BATS_LIB_PATH="test_helper/bats-support:/opt/homebrew/lib:/opt/homebrew/Cellar/bats-support/0.3.0/lib:$BATS_LIB_PATH"
   load 'test_helper/bats-support/load'
   load 'test_helper/bats-assert/load'

   # get the containing directory of this file
   # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
   # as those will point to the bats executable's location or the preprocessed file respectively
   PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/../../" >/dev/null 2>&1 && pwd )"
   # echo "$PROJECT_ROOT, $BATS_TEST_FILENAME" >&3
   # make executables in src/ visible to PATH
   PATH="$PROJECT_ROOT:/bin/:${PROJECT_ROOT}/ws_tool:$PATH"
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
   done < "$PROJECT_ROOT/ws_tool/lib/settings.bash"
   REPLY=(${all_settings[@]})
}

ws_unset_settings() {
    ws_get_all_settings
    all_settings=("${REPLY[@]}")
    unset "${all_settings[@]}"
}

ws_reset_settings () {
    ws_unset_settings
    . "$PROJECT_ROOT/ws_tool/lib/settings.bash"
}
