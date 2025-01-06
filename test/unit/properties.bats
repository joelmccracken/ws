setup (){
  load '../test_helper/helper'
  _setup_common
  . "$PROJECT_ROOT/lib/properties.bash"
}

@test "ws_prop_check_workstation_dir" {
  ws_unset_settings
  WS_DIR="$(_mktemp "ws-dir")"
  set_workstation_version_last_sha
  . "$PROJECT_ROOT/lib/settings.bash"

  run ws_prop_check_workstation_dir
  assert_failure

  run ws_prop_check_workstation_dir_fix
  assert_success

  run ws_prop_check_workstation_dir
  assert_success
}

@test "ws_prop_check_workstation_repo" {
  ws_unset_settings
  WS_DIR="$(_mktemp "ws-dir")"
  set_workstation_version_last_sha
  . "$PROJECT_ROOT/lib/settings.bash"

  # set up the workstation dir, but wont set up git, just project source
  run ws_prop_check_workstation_dir_fix
  assert_success

  run ws_prop_check_workstation_repo
  assert_failure

  # WS_REPO_ORIGIN=https://github.com/joelmccracken/ws.git
  run ws_prop_check_workstation_repo_fix
  assert_success

  run ws_prop_check_workstation_repo
  assert_success
}

@test "ws_prop_dotfiles_git_track" {
  ws_unset_settings
  FAKE_HOME="$(_mktemp "ws-fake-home")"
  set_workstation_version_last_sha

  . "$PROJECT_ROOT/lib/settings.bash"

  wrap() {
    (export HOME=$FAKE_HOME;  ws_prop_dotfiles_git_track)
  }
  run wrap
  assert_failure

  wrap() {
    (export HOME=$FAKE_HOME;  ws_prop_dotfiles_git_track_fix)
  }
  run wrap
  assert_success

  wrap() {
    (export HOME=$FAKE_HOME;  ws_prop_dotfiles_git_track)
  }
  run wrap
  assert_success
}

@test "ws_prop_config_exists default config" {
  ws_unset_settings
  WS_CONFIG="$(_mktemp "ws-fake-config")"
  set_workstation_version_last_sha
  WS_DIR="$WS_CONFIG/vendor/ws"
  . "$PROJECT_ROOT/lib/settings.bash"

  # valid scenario requires copying from where the workstation source is
  # installed; set this up.
  run ws_prop_check_workstation_dir_fix

  run ws_prop_config_exists
  assert_failure

  run ws_prop_config_exists_fix
  assert_success

  run ws_prop_config_exists
  assert_success

  for f in settings.sh config.sh settings.default.sh; do
    assert [ -f "${WS_CONFIG}/$f" ]
  done
}

@test "ws_prop_config_exists using custom config dir" {
  ws_unset_settings
  WS_CONFIG="$(_mktemp "ws-fake-config")"
  set_workstation_version_last_sha
  WS_DIR="$WS_CONFIG/vendor/ws"
  . "$PROJECT_ROOT/lib/settings.bash"

  # valid scenario requires copying from where the workstation source is
  # installed; set this up.
  run ws_prop_check_workstation_dir_fix

  run ws_prop_config_exists
  assert_failure

  ws_cli_arg_initial_config_dir="${WS_DIR}/sample_config"

  run ws_prop_config_exists_fix
  assert_success

  run ws_prop_config_exists
  assert_success

  ( cd "$ws_cli_arg_initial_config_dir";
    for f in *; do
      # utter insanity
      assert [ "$(cat $f)" == "$(cat "$WS_CONFIG/$f")" ]
    done
  )
}

@test "ws_prop_config_exists config already in place" {
  ws_unset_settings
  WS_CONFIG="$(_mktemp "ws-fake-config")"
  . "$PROJECT_ROOT/lib/settings.bash"

  touch "${WS_CONFIG}/settings.sh"
  touch "${WS_CONFIG}/config.sh"

  run ws_prop_config_exists
  assert_success
}

@test "ws_prop_config_exists use repo" {
  ws_unset_settings

  WS_CONFIG="$(_mktemp "ws-fake-config")"
  set_workstation_version_last_sha
  WS_DIR="$WS_CONFIG/vendor/ws"
  . "$PROJECT_ROOT/lib/settings.bash"

  # make a config repo
  ws_cli_arg_initial_config_repo="$(_mktemp "ws-fake-config-repo")"
  ws_cli_arg_initial_config_repo_ref='some-branch'
  ws_cli_arg_initial_config_dir=''
  ( cd "$ws_cli_arg_initial_config_repo";
    git init .;
    echo "# config stuff" > config.sh
    echo "# settings stuff" > settings.sh
    git add .;
    git commit -m 'initial commit';
    git checkout -b some-branch
  )

  run ws_prop_check_workstation_dir_fix

  run ws_prop_config_exists
  assert_failure

  run ws_prop_config_exists_fix
  #echo "$output" 1>&3
  assert_success

  run ws_prop_config_exists
  assert_success

  #ls -lah "$WS_CONFIG/" 1>&3

}

## bats test_tags=bats:focus
@test "ws_prop_current_settings_symlink works for default" {
  ws_unset_settings
  WS_CONFIG="$(_mktemp "ws-fake-config")"
  set_workstation_version_last_sha
  WS_NAME=default
  . "$PROJECT_ROOT/lib/settings.bash"

  # env 1>&3
  # return 1
  ws_prop_check_workstation_dir_fix
  ws_prop_config_exists_fix

  run ws_prop_current_settings_symlink
  assert_failure

  run ws_prop_current_settings_symlink_fix
  assert_success

  run ws_prop_current_settings_symlink
  assert_success

  # echo "$WS_CONFIG" 1>&3
  # ls -lah "$WS_CONFIG" 1>&3
}

@test "ws_prop_nix_global_config" {
  ws_unset_settings
  . "$PROJECT_ROOT/lib/settings.bash"

  nix_config="$(_mktemp "nix-config")/nix.conf"
  cat > "$nix_config" <<-EOF || :
	other config
	# BEGIN ws_prop_nix_global_config
	some old config here
	# END ws_prop_nix_global_config
	final config
EOF

  run_env() {
    WS_PROP_NIX_NIX_CONF_PATH="$nix_config";
    WS_DIR="$PROJECT_ROOT"
    "$1"
  }

  run run_env ws_prop_nix_global_config
  assert_failure

  run run_env ws_prop_nix_global_config_fix
  assert_success

  run run_env ws_prop_nix_global_config
  assert_success
}

@test "ws_prop_df_dotfiles basic dotfile test" {
  ws_unset_settings
  . "$PROJECT_ROOT/lib/settings.bash"

  df_src_dir="$(_mktemp "dotfiles-src")"
  df_dest_dir="$(_mktemp "dotfiles-dest")"

  WS_PROP_DF_SRC_DIR="$df_src_dir"
  ws_prop_df__dotfile_dest_dir="$df_dest_dir"

  cat > "$df_src_dir/bashrc" <<< "my bash config"
  cat > "$df_src_dir/Brewfile" <<< "some homebrew package"
  mkdir -p "$df_src_dir/config/git/"
  cat > "$df_src_dir/config/git/ignore" <<< ".DS_Store"

  test_ws_name=some_name_$RANDOM
  WS_NAME="$test_ws_name"

  df_fn_src_file="$(_mktemp "df-fn-src")/df.bash"
  cat > "$df_fn_src_file" <<-EOF
	workstation_props_dotfiles_${WS_NAME} () {
	  dotfile --ln --dot bashrc
	  dotfile --ln --dot --dir config/git
	  dotfile --ln Brewfile
	}
EOF
  # cat < "$df_fn_src_file" 1>&3
  eval "$(cat < "$df_fn_src_file")"

  run ws_prop_df_dotfiles
  # echo "$output" 1>&3
  assert_failure

  run ws_prop_df_dotfiles_fix
  assert_success

  run ws_prop_df_dotfiles
  assert_success

  assert [ -f "$df_dest_dir/.bashrc" ]
  assert [ -f "$df_dest_dir/Brewfile" ]
  assert [ -f "$df_dest_dir/.config/git/ignore" ]
}
