#!/usr/bin/env bash

ws_prop_nix_daemon_installed() {
  if which nix > /dev/null ; then
    echo "nix command found"
    return 0
  else
    echo "nix command not found" 1>&2
    return 1
  fi
}

WS_PROP_NIX_PM_VERSION__default() {
  # latest stable
  printf "2.24.14";
}
: "${WS_PROP_NIX_PM_VERSION:=}"

ws_prop_nix_daemon_installed_fix() {
  local nix_daemon_profile
  sh <(curl -L https://releases.nixos.org/nix/nix-$(ws_lookup WS_PROP_NIX_PM_VERSION)/install) --daemon;
  # load the needful after installing
  nix_daemon_profile='/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  if [[ ! -e "$nix_daemon_profile" ]]; then
    echo "nix installed, but cannot find profile file to load" 1>&2
    return 8
  fi

  set +u
  . "$nix_daemon_profile";
  set -u

  ws_nix__restart_daemon
}

ws_nix__restart_daemon() {
  if is_mac; then
    set +e
    sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist
    sudo launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist
    set -e
  else
    sudo systemctl restart nix-daemon.service;
  fi
}

WS_PROP_NIX_NIX_CONF_PATH__default () {
  printf "/etc/nix/nix.conf"
}

export WS_PROP_NIX_NIX_CONF_PATH
: "${WS_PROP_NIX_NIX_CONF_PATH:=}"

ws_nix__global_conf_content() {
  cat <<-EOF
	# BEGIN ws_prop_nix_global_config
	# configuration from ws property ws_prop_nix_global_config
	# AUTOMATICALLY MANAGED: region edits will be overwritten in the future
	trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=
	substituters = https://cache.nixos.org https://cache.iog.io
	experimental-features = nix-command flakes
	trusted-users = root $(whoami) runner
	build-users-group = nixbld
	# END ws_prop_nix_global_config
EOF
}

ws_prop_nix_global_config () {
  local conf="$(ws_lookup WS_PROP_NIX_NIX_CONF_PATH)"
  local begin="# BEGIN ws_prop_nix_global_config"
  local end="# END ws_prop_nix_global_config"

  REPLY=()
  find_bracketed_content "$begin" "$end" < "$conf"
  local parts=("${REPLY[@]}")
  REPLY=()
  if [[ "${parts[1]}" == "$(ws_nix__global_conf_content)"$'\n' ]]; then
    echo "config file at '$conf' is up to date"
    return 0
  else
    echo "config file at '$conf' is out of date";
    return 1
  fi
}

ws_prop_nix_global_config_fix () {
  local conf_path
  local begin="# BEGIN ws_prop_nix_global_config"
  local end="# END ws_prop_nix_global_config"
  conf_path="$(ws_lookup WS_PROP_NIX_NIX_CONF_PATH)"

  REPLY=(); find_bracketed_content "$begin" "$end" < "$conf_path";
  local parts=("${REPLY[@]}"); REPLY=();

  new_conf="$(_mktemp "nix-conf")/nix.conf"

  {
    echo "${parts[0]}";
    ws_nix__global_conf_content;
    echo "${parts[2]}"
  } > "$new_conf"

  # NOTE: this will be a wrinkle if I try compiling all ws code into a single file
  sudo "$(ws_lookup WS_DIR)/bin/safe-overwrite" "$new_conf" "$conf_path"
  # must restart for config changes to take effect
  ws_nix__restart_daemon
}

WS_PROP_NIX_HOME_MANAGER_FLAKE_OUTPUT__default() {
  wsn="$(ws_lookup WS_NAME)"
  echo -n ".#homeConfigurations.\"$wsn\".\"$(whoami)\""
}
export WS_PROP_NIX_HOME_MANAGER_FLAKE_OUTPUT
: "${WS_PROP_NIX_HOME_MANAGER_FLAKE_OUTPUT:=}"

ws_prop_nix_home_manager() {
  if which home-manager > /dev/null; then
    echo "Found home-manager executable"
    dir="$(ws_lookup WS_CONFIG)/nix"
    flake_out="$(ws_lookup WS_PROP_NIX_HOME_MANAGER_FLAKE_OUTPUT)"
    build_info="$(
      cd "$dir";
      nix build --json --dry-run  -v -L "$flake_out" --show-trace
    )"
    out_path="$(dumb_json_parse_string_value "out" "$build_info")"

    if [[ -e "$out_path" ]]; then
      echo "home manager profile flake exists"
      return 0;
    else
      echo "home manager profile flake is not built"
      return 6;
    fi
  else
    echo "Did not find home-manager executable"
    return 1
  fi
}

ws_prop_nix_home_manager_fix() {
  ws_nix__home_manager_flake_build
}

ws_nix__home_manager_flake_build() {
  export HOME_MANAGER_BACKUP_EXT
  local flake_out dir
  dir="$(ws_lookup WS_CONFIG)/nix"
  flake_out="$(ws_lookup WS_PROP_NIX_HOME_MANAGER_FLAKE_OUTPUT)"
  ( cd "$dir";
    nix --log-format raw --debug -v -L --show-trace run "${flake_out}";
  )
}

ws_cli_cmds_nix(){
  shift; # remove starting arg
  arg="$1";
  shift;
  case "$arg" in
    (daemon)
      case "$1" in
        (restart) ws_nix__restart_daemon;;
        (*) echo "unrecognized: $1";;
      esac ;;
    (home-manager)
      arg="$1";
      shift;
      case "$arg" in
        (build) ws_nix__home_manager_flake_build; return 0;;
      esac;;
    ("help") ws_nix__help "$1";;
    (*) echo "unrecognized: $arg";;
  esac
}

ws_nix__help() {
  echo "TODO write this help"
}
