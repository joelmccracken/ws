#!/usr/bin/env bash

setup (){
    load 'test_helper/helper'
    _setup_common
    . "$PROJECT_ROOT/ws_tool/lib/properties.bash"
    . "$PROJECT_ROOT/ws_tool/lib/bootstrap_doctor.bash"
}

@test "prop_ws_check_workstation_dir" {
    ws_unset_settings
    WORKSTATION_DIR="$(_mktemp "ws-dir")"
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
    WORKSTATION_DIR="$(_mktemp "ws-dir")"
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

props_test_tmp_file=
declare -a prop_exec_hist

prop_a() {
    prop_exec_hist+=("a")
    echo "in prop_a"
    echo "a" >> "$props_test_tmp_file"
    REPLY=(additional_props prop_b prop_c)
    return 0
}

prop_b() {
    prop_exec_hist+=("b")
    echo "in prop_b"
    echo "b" >> "$props_test_tmp_file"
    return 0
}

prop_c() {
    prop_exec_hist+=("c")
    echo "in prop_c"
    echo "c" >> "$props_test_tmp_file"
    return 0
}

prop_f() {
    prop_exec_hist+=("f")
    echo "f" >> "$props_test_tmp_file"
    echo "in prop_f"
    return 0
}

@test "ensure props handles additional props correctly" {
    props_test_tmp_file="$(_mktemp "props-test-tmp")/file"
    echo "iv" >> "$props_test_tmp_file"

    prop_exec_hist=(iv)
    ws_unset_settings
    run_props prop_a prop_f

    # tested two ways, just keweping for now bc I have a feeling i'll want to see this in the future
    assert_equal "${prop_exec_hist[*]}" "iv a b c f"
    declare -a 'content=($(cat "${props_test_tmp_file}"))'
    assert_equal "${content[*]}" "iv a b c f"
}
