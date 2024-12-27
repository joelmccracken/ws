workstation_props_dotfiles_gitdir=".git-dotfiles"

workstation_props__common=()
workstation_props__common+=(prop_ws_current_settings_symlink)
workstation_props__common+=(prop_ws_nix_daemon_installed)

workstation_props_ci_ubuntu=()
workstation_props_ci_ubuntu+=("${workstation_props__common[@]}")

workstation_props_ci_macos=()
workstation_props_ci_macos+=("${workstation_props__common[@]}")
