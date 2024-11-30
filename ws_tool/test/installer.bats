#!/usr/bin/env bash

setup (){
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load 'test_helper/helper'

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    PATH="$PROJECT_ROOT:/bin/:$PATH"
    # source "$PROJECT_ROOT/ws"
}

@test "runs ws_install" {
    export WORKSTATION_DIR="$(mktemp -d "/tmp/ws-dir-XXXXXX")"
    export WORKSTATION_VERSION=workcomp
    # export TO_WORKSTATION_DIR="${TMPDIR}/workstation"
    run ws_install.sh
    assert [ -x "${WORKSTATION_DIR}/ws_tool/ws" ]
}
