#!/usr/bin/env bash

# prototype of a new workstation tool. goal being an interactive tool that can be used anywhere.
# I'm much better at bash now, and think I can probably accomplish what I need to do.

# ensure macos bash used: (export PATH="/bin:$PATH"; ./ws -v)
# (ensures that any other bash processes will use builtin too)
# set -euo pipefail

# env
# exit 10;

ws_script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

ws_initial_pwd="$PWD"

# set -x
. "${ws_script_dir}/lib/settings.bash"
. "${ws_script_dir}/lib/logging.bash"
. "${ws_script_dir}/lib/lib.bash"
. "${ws_script_dir}/lib/properties.bash"
. "${ws_script_dir}/lib/bootstrap_doctor.bash"
. "${ws_script_dir}/lib/secrets.bash"

REPLY=() # global "out" var, hack to use return values
ws_cli_arg_cmd=help # show help if nothing provided
declare -a ws_cli_raw_args
# ws_cli_arg_subcommand_args
# stores the remaining CLI arguments for further parsing by subcommands
# starts with the subcommand name to avoid issues with empty arrays
declare -a ws_cli_arg_subcommand_args
: "${ws_cli_arg_initial_config_dir:=}"
: "${ws_cli_arg_ws_name:=}"
: "${ws_cli_arg_interactive:=}"
: "${ws_cli_arg_initial_config_repo:=}"
: "${ws_cli_arg_initial_config_repo_ref:=}"

ws_cli_usage_exit() {
    ws_cli_usage
    exit "$1"
}

ws_cli_usage() {
  echo "Workstation configuration tool."
  echo
  echo "Usage:"
  echo "  ws [options] bootstrap"
  echo "  ws [options] doctor"
  echo
  echo "Subcommands:"
  echo "  bootstrap     : run the bootstrap process"
  echo "  doctor        : Run checks on local setup"
  echo "  help          : display this message"
  echo
  echo "Options:"
  echo "-h --help                : Display this message and exit"
  echo "-v -verbose              : Be verbose"
  echo "-n NAME, --name NAME     : Specify the name of this workstation."
  echo "-i, --interactive        : Interactive mode."
  echo "-c, --initial-config-dir : Initial configuration directory."
  echo "       If user already has a workstation configuration, "
  echo "       specifies location for tool to use it."
  echo "       Installs this configuration at default configuration location."
}

ws_cli_proc_args() {
  ws_cli_raw_args=("$@")
  local args=("$@")
  local i;                      #
  for ((i=0;i < ${#args[@]}; i++)); do
    debug "iter:$i ; current:${args[i]} ; max:${#args[@]}"
    local current="${args[i]}"

    case "$current" in
      (-v|--verbose)
        WS_VERBOSE=true
        WS_LOG_LEVEL=info
        ;;
      (-n|--name)
        ws_cli_arg_ws_name="${args[i+1]}";
        (( i+=1 ));
        ;;
      (--initial-config-dir)
        ws_cli_arg_initial_config_dir="${args[i+1]}";
        (( i+=1 ));
        ;;
      (--initial-config-repo)
        ws_cli_arg_initial_config_repo="${args[i+1]}";
        (( i+=1 ));
        ;;
      (--initial-config-repo-ref)
        ws_cli_arg_initial_config_repo_ref="${args[i+1]}";
        (( i+=1 ));
        ;;
      (-h|--help|help)
        ws_cli_usage_exit 0;
        ;;
      (-i|--interactive)
        ws_cli_arg_interactive=true;
        ;;
      (bootstrap|doctor|sh|secrets|nix)
        ws_cli_arg_cmd="$current";
        ws_cli_arg_subcommand_args=("${args[@]:i}")
        break;
        ;;
      (*)
        error "ws: argument parsing: unknown argument '$current'";
        exit 10;
        ;;
    esac
  done

  return 0
}

ws_cli_cmds_help() {
  ws_cli_usage_exit 0;
}

ws_cli_main() {
  set -x
  ws_cli_proc_args "$@"
  [ -n "$ws_cli_arg_ws_name" ] && WS_NAME="$ws_cli_arg_ws_name"

  if [ "$(ws_lookup WS_VERBOSE)" = "true" ]; then
    set -x
  fi

  # if [[ -n "$ws_cli_arg_initial_config_dir" ]]; then
  #   load_expected "$ws_cli_arg_initial_config_dir/settings.sh"
  #   load_expected "$ws_cli_arg_initial_config_dir/config.sh"
  # fi

  if [[ -d "$(ws_lookup WS_CONFIG)" ]]; then
    load_expected "$(ws_lookup WS_CONFIG)/settings.sh"
    load_expected "$(ws_lookup WS_CONFIG)/config.sh"
  fi

  case "$ws_cli_arg_cmd" in
    (bootstrap) ws_cli_cmds_bootstrap "${ws_cli_arg_subcommand_args[@]}";;
    (doctor) ws_cli_cmds_doctor "${ws_cli_arg_subcommand_args[@]}";;
    (sh) ws_cli_cmds_sh "${ws_cli_arg_subcommand_args[@]}";;
    (secrets) ws_cli_cmds_secrets "${ws_cli_arg_subcommand_args[@]}";;
    (nix) ws_cli_cmds_nix "${ws_cli_arg_subcommand_args[@]}";;
    ("help") ws_cli_cmds_help "${ws_cli_arg_subcommand_args[@]}";;
    (*) error "unknown command $ws_cli_arg_cmd; how did we get here?"
  esac
}

ws_cli_cmds_sh() {
  bash
}
# if being run directly, run main
(return 0 2>/dev/null) || ws_cli_main "$@"
