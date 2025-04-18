#!/usr/bin/env bash
set -euo pipefail

declare -a REPLY

# bootstrapping and doctoring is closely related enough for now
# decide to keep these in the same file.
ws_cli_cmds_doctor() {
  shift # remove useless arg
  echo "doctor!";
  run_all_props --fix false --label "doctor"
}

ws_cli_cmds_bootstrap_setup() {
  if [[ -z "$(ws_lookup WS_NAME)" ]]; then
    error "ws: bootstrap: unable to determine workstation name. Provide it as an argument or env var"
    exit 1
  fi
}

: "${ws_bootstrap__cli_arg_initial_config_dir:=}"
: "${ws_bootstrap__cli_arg_ws_name:=}"
: "${ws_bootstrap__cli_arg_initial_config_repo:=}"
: "${ws_bootstrap__cli_arg_initial_config_repo_ref:=}"


ws_bootstrap__cli_proc_args() {
  shift; # remove initial "bootstrap" from front
  local args=("$@")
  local i;
  for ((i=0;i < ${#args[@]}; i++)); do
    local current="${args[i]}"
    case "$current" in
      (-n|--name)
        ws_bootstrap__cli_arg_ws_name="${args[i+1]}";
        (( i+=1 ));
        ;;
      (--initial-config-dir)
        ws_bootstrap__cli_arg_initial_config_dir="${args[i+1]}";
        (( i+=1 ));
        ;;
      (--initial-config-repo)
        ws_bootstrap__cli_arg_initial_config_repo="${args[i+1]}";
        (( i+=1 ));
        ;;
      (--initial-config-repo-ref)
        ws_bootstrap__cli_arg_initial_config_repo_ref="${args[i+1]}";
        (( i+=1 ));
        ;;
      (*)
        error "ws bootstrap: argument parsing: unknown argument '$current'";
        exit 10;
        ;;
    esac;
  done
}

ws_cli_cmds_bootstrap() {
  ws_bootstrap__cli_proc_args "$@"
  [ -n "$ws_bootstrap__cli_arg_ws_name" ] && WS_NAME="$ws_bootstrap__cli_arg_ws_name"
  run_all_props --fix true --label "bootstrap"
}

run_all_props() {
  local fix="" label="" wsn
  wsn="$(ws_lookup WS_NAME)"

  if (( $# != 4 )); then
    echo "requires both --fix <val> and --label <val> flags" 1>&2
  fi

  while (( $# > 0 )); do
    local current="$1"
    shift
    case "$current" in
      (--fix) fix="$1"; shift;;
      (--label) label="$1"; shift;;
      (*) echo "unknown argument '$current', remaining arguments '$*'"; return 10;;
    esac
  done

  echo "$label: base properties"
  local result=0
  run_props --fix "$fix" "${bootstrap_props[@]}" || { result="$?"; : ; }
  if (( result > 0 )); then
    return "$result";
  fi

  echo "$label: '$wsn' properties"

  REPLY=()
  get_workstation_properties
  local ws_props=()
  (( ${#REPLY[@]} > 0)) && ws_props=("${REPLY[@]}") || return 0
  REPLY=()
  if (( ${#ws_props[@]} > 0)); then
    echo "$label: $wsn properties: (${ws_props[*]})"
    run_props --fix "$fix" "${ws_props[@]}"
  else
     echo "no properties defined for '$wsn'"
  fi
}

get_workstation_properties() {
  local ws_props_ptr
  ws_props_ptr="workstation_props_$(ws_lookup WS_NAME)"
  if declare -p "$ws_props_ptr" &> /dev/null; then
    printf -v setprops 'props=("${%s[@]}");' "$ws_props_ptr"
    eval "$setprops"
    REPLY=("${props[@]}")
  else
    REPLY=()
  fi
  return 0
}

bootstrap_props=(
  ws_prop_check_workstation_dir
  ws_prop_check_initial_tooling_setup
  ws_prop_check_workstation_repo
  ws_prop_config_exists
)

run_props () {
  local fix=
  if [[ "$1" == "--fix" ]]; then
    fix="$2";
    shift; shift;
  else
     echo "run_props: arguments: must specify --fix <bool> parameter as starting parameter" 1>&2
     return 8
  fi

  local initial_props=("$@")
  local props=("${initial_props[@]}")
  local prop_result fix_result
  local current
  local failed_props=()

  while (($#)); do
    local current="$1" prop_result
    shift
    echo "checking: $current..."
    REPLY=()
    prop_result=0
    "$current" || { prop_result="$?"; : ; }
    if (( ${#REPLY[@]} > 1 )) && [[ "${REPLY[0]}" == "additional_props" ]]; then
      additional_props=("${REPLY[@]:1}")
      REPLY=() # unset to prevent any confusion on next run
      echo  "$current defines additional properties, adding to top of properties to check: (${additional_props[@]})"
      set "${additional_props[@]}" "$@"
    fi
    if (( prop_result == 0 )); then
      echo "checking: $current ... OK"
    else
      echo "checking: $current ... FAIL"
      if [[ "$fix" == "true" ]]; then
        echo "fixing: $current ..."
        local fix_result=0
        interact "${current}_fix" || { fix_result="$?"; : ; }
        if (( fix_result == 0 )); then
          echo "fixing: $current .... OK"
          prop_result=0
          "${current}" || { prop_result="$?"; : ; }
          if (( prop_result == 0 )); then
            echo "checking: $current .... OK"
          else
            echo "checking: $current .... FAIL"
            echo "prop $current still failing after running fix, aborting";
            return "$prop_result"
          fi
        else
          echo "fixing: $current .... FAIL"
          echo "error while fixing $current, aborting"
          return 88
        fi
      else
        failed_props+=("$current")
      fi
    fi
  done

  if (( ${#failed_props[@]} > 0 ));  then
     echo "ws: ${label}: unable to satisfy the following props:" 1>&2
     for prop in "${failed_props[@]}"; do
       echo "    - $prop" 1>&2
     done
     echo " Examine earlier log output to see what went wrong." 1>&2
     return 10
  else
     return 0
  fi
}

: "${interact_always_continue:=false}"
do_interact() {
  # only interact if stdin is a terminal,
  # the ws_cli_arg_interactive variable is set to true,
  # and interact_always_continue is not set to true
  [[ -t 0 ]] && \
    [[ "${ws_cli_arg_interactive:-false}" == "true" ]] && \
    [[ "${interact_always_continue:-false}" != "true" ]]
}

interact() {
  local has_continue=0 the_command="$1" result

  if do_interact ; then
    while [ "$has_continue" != "1" ]; do
      read -r -e -n 1 -p "About to run '$1', continue? (c/q/!/p/?):" response
      case "$response" in
        (c) has_continue=1;;
        (q) echo "quitting..."; exit 0;;
        (\!) interact_always_continue=1; has_continue=1;;
        (p) type "$the_command";;
        (?) interact_help;;
        (*) echo "unrecognized response '$response'."
      esac
    done
  fi

  # if we're here, we must have gotten continue
  # or not needed to interact
  result=0
  "$the_command" || { result="$?"; : ; }
  return "$result";
}

interact_help() {
  echo "c=continue, q=quit, !=always continue, p=print function definition, ?=print this help";
}
