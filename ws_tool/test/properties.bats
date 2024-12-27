setup (){
    load 'test_helper/helper'
    _setup_common
    . "$PROJECT_ROOT/ws_tool/lib/properties.bash"
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

@test "prop_ws_dotfiles_git_track" {
    ws_unset_settings
    FAKE_HOME="$(_mktemp "ws-fake-home")"
    WORKSTATION_VERSION=workcomp

    . "$PROJECT_ROOT/ws_tool/lib/settings.bash"

    wrap() {
        (export HOME=$FAKE_HOME;  prop_ws_dotfiles_git_track)
    }
    run wrap
    assert_failure

    wrap() {
        (export HOME=$FAKE_HOME;  prop_ws_dotfiles_git_track_fix)
    }
    run wrap
    assert_success

    wrap() {
        (export HOME=$FAKE_HOME;  prop_ws_dotfiles_git_track)
    }
    run wrap
    assert_success
}

@test "prop_ws_config_exists default config" {
    ws_unset_settings
    WORKSTATION_CONFIG_DIR="$(_mktemp "ws-fake-config")"
    WORKSTATION_VERSION=workcomp
    WORKSTATION_DIR="$WORKSTATION_CONFIG_DIR/workstation_source"
    . "$PROJECT_ROOT/ws_tool/lib/settings.bash"

    # valid scenario requires copying from where the workstation source is
    # installed; set this up.
    run prop_ws_check_workstation_dir_fix

    run prop_ws_config_exists
    assert_failure

    run prop_ws_config_exists_fix
    assert_success

    run prop_ws_config_exists
    assert_success

    for f in settings.sh config.sh settings.default.sh; do
        assert [ -f "${WORKSTATION_CONFIG_DIR}/$f" ]
    done
}

@test "prop_ws_config_exists using custom config" {
    ws_unset_settings
    WORKSTATION_CONFIG_DIR="$(_mktemp "ws-fake-config")"
    WORKSTATION_VERSION=workcomp
    WORKSTATION_DIR="$WORKSTATION_CONFIG_DIR/workstation_source"
    . "$PROJECT_ROOT/ws_tool/lib/settings.bash"

    # valid scenario requires copying from where the workstation source is
    # installed; set this up.
    run prop_ws_check_workstation_dir_fix

    run prop_ws_config_exists
    assert_failure

    workstation_initial_config_dir_arg="${WORKSTATION_DIR}/ws_tool/my_config"

    run prop_ws_config_exists_fix
    assert_success

    run prop_ws_config_exists
    assert_success

    (
    cd "$workstation_initial_config_dir_arg"
    for f in *; do
      # utter insanity
      assert [ "$(cat $f)" == "$(cat "$WORKSTATION_CONFIG_DIR/$f")" ]
    done
    )
}

@test "prop_ws_config_exists config already in place" {
    ws_unset_settings
    WORKSTATION_CONFIG_DIR="$(_mktemp "ws-fake-config")"
    . "$PROJECT_ROOT/ws_tool/lib/settings.bash"

    touch "${WORKSTATION_CONFIG_DIR}/settings.sh"
    touch "${WORKSTATION_CONFIG_DIR}/config.sh"

    run prop_ws_config_exists
    assert_success
}

@test "prop_ws_current_settings_symlink works for default" {
    ws_unset_settings
    WORKSTATION_CONFIG_DIR="$(_mktemp "ws-fake-config")"
    WORKSTATION_VERSION=workcomp
    WORKSTATION_NAME=default
    . "$PROJECT_ROOT/ws_tool/lib/settings.bash"

    prop_ws_check_workstation_dir_fix
    prop_ws_config_exists_fix

    run prop_ws_current_settings_symlink
    assert_failure

    run prop_ws_current_settings_symlink_fix
    assert_success

    run prop_ws_current_settings_symlink
    assert_success

    # echo "$WORKSTATION_CONFIG_DIR" 1>&3
    # ls -lah "$WORKSTATION_CONFIG_DIR" 1>&3
}
