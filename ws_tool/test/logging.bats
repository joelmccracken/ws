#!/usr/bin/env bash
setup (){
    load 'test_helper/helper'
    _setup_common
    . "$PROJECT_ROOT/ws_tool/lib/logging.bash"
}

@test "trying logging code" {
    export BATS_VERBOSE_RUN=true
    run retfunc log_level_num error
    assert_output --partial 'VAR:REPLY=4'
}

@test "logs by log level" {
    WORKSTATION_LOG_LEVEL=debug
    run debug "hello world" 2>&1
    assert_output --partial 'hello world'
}

@test "skips logs when out of log level" {
    WORKSTATION_LOG_LEVEL=error
    run debug "hello world" 2>&1
    refute_output --partial 'hello world'
}

@test "skips logs when out of log levelf" {
    WORKSTATION_LOG_LEVEL=error
    run debug "hello world" 2>&1
    refute_output --partial 'hello world'
}
