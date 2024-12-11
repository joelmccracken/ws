#!/usr/bin/env bash

setup (){
    load 'test_helper/helper'
    _setup_common
    . "$PROJECT_ROOT/ws_tool/lib/bootstrap_doctor.bash"
}

@test "prop_ws_check_workstation_dir" {
    ws_unset_settings
    WORKSTATION_DIR="/tmp/workstation-dir-$RANDOM"
    WORKSTATION_VERSION=workcomp
    . "$PROJECT_ROOT/ws_tool/lib/settings.bash"

    run prop_ws_check_workstation_dir
    assert_failure

    run prop_ws_check_workstation_dir_fix
    assert_success

    run prop_ws_check_workstation_dir
    assert_success
}

@test "prop_ws_check_workstation_repo" {
    ws_unset_settings
    WORKSTATION_DIR="/tmp/workstation-dir-$RANDOM"
    WORKSTATION_VERSION=workcomp
    . "$PROJECT_ROOT/ws_tool/lib/settings.bash"

    # set up the workstation dir, but wont set up git, just project source
    run prop_ws_check_workstation_dir_fix
    assert_success

    run prop_ws_check_workstation_repo
    assert_failure

    # WORKSTATION_REPO_GIT_ORIGIN=https://github.com/joelmccracken/workstation.git
    run prop_ws_check_workstation_repo_fix
    assert_success

    run prop_ws_check_workstation_repo
    assert_success
}
