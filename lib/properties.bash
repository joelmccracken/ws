#!/usr/bin/env bash

. "$(ws_lookup WS_DIR)/lib/properties/dotfiles.bash"
. "$(ws_lookup WS_DIR)/lib/properties/nix.bash"
. "$(ws_lookup WS_DIR)/lib/properties/secrets.bash"

# writing properties
# for a given property foo, define function
# prop_foo
# that determines if property is fulfilled.
# return code 0 indicates its fulfilled,
# nonzero code indicates property is notfulfilled.
# if propery is not fulfilled,
# prop_foo_fix is executed to
# try to fix/fulfill the property.
# after prop_foo_fix completes, if it has zero exit code,
# assume it worked. run original prop function again to ensure
# if prop does not pass now, exit prop checking and fulfilling cycle
# as fix did not work
#
# propery functions can define that they depend upon other properties by
# setting the REPLY global to an array where the first argument is
# "additional_props" and subsequent arguments are those properties. for example,
# say above property foo should have other props bar and baz, then the following
# value would be appropriate:
#   REPLY=(additional_props prop_bar prop_baz)
# after prop foo returns with a zero exit code, these props are handled next.
# By default, prop_foo would not be checked again after the other props are fulfilled, but
# you could make it do this by for example
#   prop_foo() {
#    REPLY=(additional_props prop_bar prop_baz prop_foo)
#   }
# Note that prop_foo is included at the end of the additional properties list.
# Of course, you wouldn't want this exact example, otherwise it would imply
# that foo would be checked again and again, ad infinitum.

ws_prop_check_initial_tooling_setup()
{
  if is_mac; then
    REPLY=(additional_props \
      ws_prop_check_mac_cli_tools\
      ws_prop_check_mac_homebrew_installed\
      ws_prop_check_mac_git_installed\
      )
    return 0
  else
    if is_linux; then
      REPLY=(additional_props ws_prop_check_linux_git_installed)
      return 0
    else
      # TODO linux is assumed to be debian based
      error "unable to determine workstation system type (mac, linux)"
      return 1
    fi
  fi
}

# check to ensure that xcode cli tools are installed
# this command will tell without itself trying to install them
ws_prop_check_mac_cli_tools () {
  if pkgutil --pkg-info=com.apple.pkg.CLTools_Executables; then
    echo "cli tools package is installed";
    return 0
  else
    echo "cli tools package not installed" 1>&2
    return 1
  fi
}

ws_prop_check_mac_cli_tools_fix () {
  sudo bash -c '(xcodebuild -license accept; xcode-select --install) || exit 0'
}

ws_prop_check_mac_homebrew_installed() {
  if which brew > /dev/null; then
    echo "homebrew is installed"
    return 0
  else
    echo "homebrew is not installed" 1>&2;
    return 1
  fi
}

ws_prop_check_mac_homebrew_installed_fix() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

ws_prop_check_mac_git_installed() {
  if which git > /dev/null; then
    echo "git is detected"
  else
    echo "no git is detected"
  fi
}

ws_prop_check_mac_git_installed_fix() {
  brew install git
}

ws_prop_check_linux_git_installed() {
  if which git > /dev/null; then
    echo "git is detected"
  else
    echo "no git is detected"
  fi
}

ws_prop_check_linux_git_installed_fix() {
  sudo bash -c 'apt-get update && apt-get install git'
}

ws_prop_check_workstation_dir() {
  local wsd
  wsd="$(ws_lookup WS_DIR)"
  if [ -d "$wsd" ]; then
    echo "WS_DIR exists"
    if [ -x "$wsd/ws" ]; then
      echo "WS_DIR contains ws executable"
      return 0
    else
      echo "$wsd does not contain the ws tool" 1>&2
      return 2
    fi
  else
    echo "$wsd (WS_DIR) is absent" 1>&2
    echo "(is workstation installed to a custom location? set WS_DIR=path/to/workstation)" 1>&2
    return 1
  fi
}

ws_prop_check_workstation_dir_fix() {
  # TODO this is basically a copy/paste of ws_install.sh
  # somehow figure out another way to do this?
  TMPINST="$(mktemp -d "${TMPDIR:-/tmp}/ws-install-XXXXXXXXX")"
  # installer of ws tool/project
  ( cd "$TMPINST";
    curl -L https://github.com/joelmccracken/ws/archive/$(ws_lookup WS_VERSION).tar.gz | tar zx;
    local wsd
    wsd="$(ws_lookup WS_DIR)"
    mkdir -p "$wsd";
    mv "${TMPINST}"/ws-*/{,.[^.]}* "$wsd";
  )
}

ws_prop_check_workstation_repo() {
  local wsd
  wsd="$(ws_lookup WS_DIR)"
  if [ -d "$wsd/.git" ]; then
    echo "WS_DIR git directory exists"
    return 0
  else
    echo "$wsd/.git directory is absent" 1>&2
    return 1
  fi
}

ws_prop_check_workstation_repo_fix() {
  ( cd "$(ws_lookup WS_DIR)";
    git init .;
    git remote add origin "$(ws_lookup WS_REPO_ORIGIN)";
    git fetch;
    git reset --mixed "$(ws_lookup WS_VERSION_REPO_FIX)";
  )
}

WS_PROP_DF_GIT_DIR__default() {
  printf ".git-dotfiles"
}
: "${WS_PROP_DF_GIT_DIR:=}"

ws_prop_dotfiles_git_track() {
  local gd
  gd="$(ws_lookup WS_PROP_DF_GIT_DIR)"
  if [ -d "$HOME/$gd" ]; then
    echo "git directory at $HOME/$gd exists"
    return 0
  else
    echo "git directory at $HOME/$gd not found" 1>&2
    return 1
  fi
}

ws_prop_dotfiles_git_track_fix() {
  export GIT_DIR
  GIT_DIR="$(ws_lookup WS_PROP_DF_GIT_DIR)"
  ( cd "$HOME";
    git init .
    git config --local --get-all core.bare true >/dev/null && \
      git config --local --replace-all core.bare false true
  )
  return 0
}

ws_prop_config_exists() {
  local settings_file config_file wcd
  wcd="$(ws_lookup WS_CONFIG)"
  settings_file="$wcd/settings.sh"
  config_file="$wcd/config.sh"
  if [[ -f "$settings_file" ]] && [[ -f "$config_file" ]]; then
    echo "found settings and config file exist."
    return 0;
  else
    if ! [[ -f "$settings_file" ]]; then
      echo "ws: bootstrap: ws_prop_config_exists: missing settings file from '$settings_file'" 1>&2
    fi
    if ! [[ -f "$config_file" ]]; then
      echo "ws: bootstrap: ws_prop_config_exists: missing config file from '$config_file'" 1>&2
    fi
    return 1
  fi
}

# depends upon ws_prop_check_workstation_dir
# TODO automate/enforce this somehow?
ws_prop_config_exists_fix() {
  local wcd
  wcd="$(ws_lookup WS_CONFIG)"
  if [[ -n "$ws_bootstrap__cli_arg_initial_config_repo" ]]; then
    ws_prop_config_exists_install_from_repo
  else
    ws_prop_config_exists_install_from_directory
  fi

  # TODO this pattern is repeated in a few places, add a
  # "load from config" function
  if [[ -n "$wcd" ]]; then
    load_expected "$wcd/settings.sh"
    load_expected "$wcd/config.sh"
  fi
}

ws_prop_config_exists_install_from_directory() {
  local src_dir wcd wsd
  wsd="$(ws_lookup WS_DIR)"
  src_dir="$wsd/sample_config";
  wcd="$(ws_lookup WS_CONFIG)"

  # TODO convert cli params to ws_lookup settings

  if [[ -n "$ws_bootstrap__cli_arg_initial_config_dir" ]]; then
    src_dir="$ws_bootstrap__cli_arg_initial_config_dir";
  fi

  # if [[ -e  "$WS_CONFIG" ]]; then
  #   mv_to_backup "$WS_CONFIG"
  # fi
  mkdir -p "$wcd"

  # hack, because if a relative dir is used for $ws_bootstrap__cli_arg_initial_config_dir
  # we want it to go back...
  ( cd "$ws_initial_pwd"; cd "$src_dir";
    # not perfect, but not worth making much more complicated
    for f in *; do
      if [[ -e "$wcd/$f" ]]; then
        echo "$wcd/$f: aleady exists, skipping"
      else
        echo "copying file to $wcd/$f"
        cp -r "$f" "$wcd/$f";
      fi
    done
  )
}

ws_prop_config_exists_install_from_repo() {
  local ref="main";
  local src_dir wcd wsd
  wsd="$(ws_lookup WS_DIR)"
  src_dir="$wsd/sample_config";
  wcd="$(ws_lookup WS_CONFIG)"

  # TODO convert cli params to ws_lookup settings
  if [[ -n "$ws_bootstrap__cli_arg_initial_config_repo_ref" ]]; then
    ref="$ws_bootstrap__cli_arg_initial_config_repo_ref"
  fi
  ws_tmp=
  if [[ -e  "$wcd" ]]; then
    ws_tmp="$(_mktemp "ws-tmp")"
    ( cd "$wcd";
      for f in * .*; do
        if [[ "$f" == '.' ]] || [[ "$f" == '..' ]]; then continue; fi
        mv "$f" "$ws_tmp"
      done
    )
  fi

  mkdir -p "$wcd"

  ( cd "$wcd";
    git clone "$ws_bootstrap__cli_arg_initial_config_repo" .;
    git checkout "$ref";
    if [[ -n "$ws_tmp" ]]; then
      ( cd "$ws_tmp";
        for f in * .*; do
          if [[ "$f" == '.' ]] || [[ "$f" == '..' ]]; then continue; fi
          cp -r "$f" "$wcd"
        done
      )
    fi
  )
}

ws_prop_current_settings_symlink() {
  local current_settings_file
  current_settings_file="$(ws_lookup WS_CONFIG)/settings.current.sh"
  if [[ -L "$current_settings_file" ]]; then
    echo "symlink found at $current_settings_file"
    return 0
  fi
  if ! [[ -e "$current_settings_file" ]]; then
    echo "no file found at '$current_settings_file'" 1>&2
  elif ! [[ -L "$current_settings_file" ]]; then
    {
      echo "Warning: File found at '$current_settings_file', but it was not a symlink."
      echo "  This will probably work, but its possible that something wonky"
      echo "  has happened."
    } 1>&2
  fi

  return 2
}

# depends upon ws_prop_config_exists
ws_prop_current_settings_symlink_fix() {
  local wcd wsd
  wcd="$(ws_lookup WS_CONFIG)"

  current_settings_file="$wcd/settings.current.sh"
  src_settings_file="$wcd/settings.$(ws_lookup WS_NAME).sh"

  ws_prop_config_exists

  if [[ -e "$current_settings_file" ]] && \
    ! [[ -L "$current_settings_file" ]]; then
    echo "non-symlink file exists at '$current_settings_file'. Cannot automatically fix." 1>&2
    return 10
  fi

  if ! [[ -e "$src_settings_file" ]]; then
    echo "Expecting to find file at '$src_settings_file' to use as symlink src. File not found." 1>&2
    return 3
  fi

  ln -s "$src_settings_file" "$current_settings_file"
  . "$current_settings_file"
}


WS_PROP_HOMEBREW_BUNDLE_BREWFILE__default() {
  echo -n "$(ws_lookup WS_CONFIG)/Brewfile"
}
: "${WS_PROP_HOMEBREW_BUNDLE_BREWFILE:=}"

ws_prop_homebrew_bundle() {
  local brewfile
  brewfile="$(ws_lookup WS_PROP_HOMEBREW_BUNDLE_BREWFILE)"

  export HOMEBREW_BUNDLE_FILE="$brewfile"
  brew bundle check
}

ws_prop_homebrew_bundle_fix() {
  local brewfile
  brewfile="$(ws_lookup WS_PROP_HOMEBREW_BUNDLE_BREWFILE)"
  export HOMEBREW_BUNDLE_FILE="$brewfile"
  brew bundle install
}
