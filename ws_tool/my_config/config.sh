

workstation_props_angrist=()
workstation_props_angrist+=(prop_ws_current_settings_symlink)
workstation_props_angrist+=(prop_ws_nix_daemon_installed)

workstation_props_dotfiles_gitdir=".git-dotfiles"

workstation_props_dotfiles_angrist() {
  ln_dotfile bashrc
  ln_dotfile ghci
  ln_dotfile gitconfig
  ln_dotfile hammerspoon
  ln_dotfile nix-channels
  ln_dotfile npmrc
  ln_dotfile reddup.yml
  ln_dotfile zshrc

  ln_norm Brewfile
  ln_norm Brewfile.lock.json
  ln_norm bitbar

  ln_dotfile_n config/git
  ln_dotfile_n config/doom

}
