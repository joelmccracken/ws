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
    source "$PROJECT_ROOT/ws"
}

@test "trying logging code" {
    export BATS_VERBOSE_RUN=true
    run retfunc log_level_num error
    assert_output --partial 'VAR:__ret=4'
}

@test "logs by log level" {
    WS_LOG_LEVEL=debug
    run debug "hello world" 2>&1
    assert_output --partial 'hello world'
}

@test "skips logs when out of log level" {
    WS_LOG_LEVEL=error
    run debug "hello world" 2>&1
    refute_output --partial 'hello world'
}

@test "skips logs when out of log levelf" {
    WS_LOG_LEVEL=error
    run debug "hello world" 2>&1
    refute_output --partial 'hello world'
}

# export WS_COMMAND_ARGUMENTS=(bootstrap glamdring); source ws; process_cli_args; echo $?
