setup (){
    load '../test_helper/helper'
    _setup_common
    . "$PROJECT_ROOT/ws_tool/lib/properties.bash"
}

@test "prop_ws_check_workstation_dir" {
    ws_unset_settings
    WORKSTATION_DIR="$(_mktemp "ws-dir")"
    set_workstation_version_last_sha
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
    set_workstation_version_last_sha
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
    set_workstation_version_last_sha

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
    set_workstation_version_last_sha
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
    set_workstation_version_last_sha
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

    ( cd "$workstation_initial_config_dir_arg";
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
    set_workstation_version_last_sha
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

@test "prop_ws_nix_global_config" {
    ws_unset_settings
    . "$PROJECT_ROOT/ws_tool/lib/settings.bash"

    nix_config="$(_mktemp "nix-config")/nix.conf"
    cat > "$nix_config" <<-EOF || :
	other config
	# BEGIN prop_ws_nix_global_config
	some old config here
	# END prop_ws_nix_global_config
	final config
EOF


    run_env() {
      WS_NIX_GLOBAL_CONFIG_LOCATION="$nix_config";
      WORKSTATION_DIR="$PROJECT_ROOT"
      "$1"
    }

    run run_env prop_ws_nix_global_config
    assert_failure

    run run_env prop_ws_nix_global_config_fix
    assert_success

    run run_env prop_ws_nix_global_config
    assert_success
}

@test "prop_ws_df_dotfiles" {
    ws_unset_settings
    . "$PROJECT_ROOT/ws_tool/lib/settings.bash"

    df_src_dir="$(_mktemp "dotfiles-src")"
    df_target_dir="$(_mktemp "dotfiles-target")"


    cat > "$df_src_dir/bashrc" <<< "my bash config"
    test_ws_name=some_name_$RANDOM
    WORKSTATION_NAME="$test_ws_name"

    eval "$(cat <<-EOF || :)"
	echo foo
EOF
    # workstation_props_dotfiles_angrist() {
    # run_env() {
    #   WS_NIX_GLOBAL_CONFIG_LOCATION="$nix_config";
    #   WORKSTATION_DIR="$PROJECT_ROOT"
    #   "$1"
    # }

    # run run_env prop_ws_nix_global_config
    # assert_failure

    # run run_env prop_ws_nix_global_config_fix
    # assert_success

    # # echo "nix_config:$(cat $nix_config)"

    # run run_env prop_ws_nix_global_config
    # assert_success
}
