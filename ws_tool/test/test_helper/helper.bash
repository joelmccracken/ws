#!/usr/bin/env bash

_setup_common() {
   # BATS_LIB_PATH="test_helper/bats-support:/opt/homebrew/lib:/opt/homebrew/Cellar/bats-support/0.3.0/lib:$BATS_LIB_PATH"
   load 'test_helper/bats-support/load'
   load 'test_helper/bats-assert/load'

   # get the containing directory of this file
   # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
   # as those will point to the bats executable's location or the preprocessed file respectively
   PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/../../" >/dev/null 2>&1 && pwd )"
   # echo "$PROJECT_ROOT" >&3
   # make executables in src/ visible to PATH
   PATH="$PROJECT_ROOT:/bin/:${PROJECT_ROOT}/ws_tool:$PATH"
}

retfunc() {
    # use set -o posix
    # plus saving and restoring sets
    # to make set print vars (and not functions)
    local orig_sets=$(set +o)
    set -o posix
    "$@";

    set | while read i; do
        printf "VAR:%s" "$i";
    done
    # declare -p __ret
    eval "$orig_sets"
}


dump_output() {
    echo "$output" 1>&3
}
