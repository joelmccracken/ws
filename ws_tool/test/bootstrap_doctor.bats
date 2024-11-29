#!/usr/bin/env bash

setup (){
    unset
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load 'test_helper/helper'

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    PATH="$PROJECT_ROOT:/bin/:$PATH"
    . "$PROJECT_ROOT/lib/bootstrap_doctor.bash"
}

@test "prop_ws_check_workstation_dir" {
    # export BATS_VERBOSE_RUN=true

    WORKSTATION_DIR="$PROJECT_ROOT"
    run prop_ws_check_workstation_dir
    assert_success

    # not mktemp because we don't want the dir to exist
    WORKSTATION_DIR="/tmp/workstation-dir-$RANDOM"
    run prop_ws_check_workstation_dir
    assert_failure

    run prop_ws_check_workstation_dir_fix
    assert_success

    run prop_ws_check_workstation_dir
    assert_success
}

@test "prop_ws_check_workstation_repo" {
    WORKSTATION_DIR="/tmp/workstation-dir-$RANDOM/"
    # TODO handel GIT ORIGIN SETTING BETTER
    WORKSTATION_REPO_GIT_ORIGIN=https://github.com/joelmccracken/workstation.git

    # set up the workstation dir, but wont set up git, just project source
    prop_ws_check_workstation_dir_fix

    run prop_ws_check_workstation_repo
    assert_failure

    run prop_ws_check_workstation_repo_fix
    assert_success

    run prop_ws_check_workstation_repo
    assert_success
}



# @test "logs by log level" {
#     WORKSTATION_LOG_LEVEL=debug
#     run debug "hello world" 2>&1
#     assert_output --partial 'hello world'
# }

# @test "skips logs when out of log level" {
#     WORKSTATION_LOG_LEVEL=error
#     run debug "hello world" 2>&1
#     refute_output --partial 'hello world'
# }

# @test "skips logs when out of log levelf" {
#     WORKSTATION_LOG_LEVEL=error
#     run debug "hello world" 2>&1
#     refute_output --partial 'hello world'
# }

# # export WS_COMMAND_ARGUMENTS=(bootstrap glamdring); source ws; process_cli_args; echo $?
