workstation_props__common=()
workstation_props__common+=(ws_prop_current_settings_symlink)
workstation_props__common+=(ws_prop_dotfiles_git_track)
workstation_props__common+=(ws_prop_nix_daemon_installed)
workstation_props__common+=(ws_prop_nix_global_config)
workstation_props__common+=(ws_prop_df_dotfiles)

workstation_props_ci_ubuntu=()
workstation_props_ci_ubuntu+=("${workstation_props__common[@]}")

workstation_props_ci_macos=()
workstation_props_ci_macos+=("${workstation_props__common[@]}")


workstation_props_dotfiles__common() {
  dotfile --ln --dot bashrc
}

workstation_props_dotfiles_ci_ubuntu() {
  workstation_props_dotfiles__common;
}

workstation_props_dotfiles_ci_macos() {
  workstation_props_dotfiles__common;
}
