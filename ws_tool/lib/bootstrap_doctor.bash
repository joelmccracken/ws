#!/usr/bin/env bash

set -euo pipefail

# bootstrapping and doctoring is closely related enough for now
# decide to keep these in the same file.
doctor_command() {
  echo "doctor!";
  prop_ws_check_workstation_dir
  prop_ws_settings_file_check
}

bootstrap_command_setup() {
  if [[ -f "$WORKSTATION_SETTINGS_FILE" ]] ; then
      info "found settings file, loading";
      . "$WORKSTATION_SETTINGS_FILE";
  fi

  if [[ -z "$WORKSTATION_NAME" ]]; then
    error "ws: bootstrap: unable to determine workstation name. Provide it as an argument or env var"
    exit 1
  fi
}

bootstrap_command() {
  echo "bootstrapping base properties"

  ensure_props "${bootstrap_props[@]}"

  echo "bootstrapping workstation properties for ${WORKSTATION_NAME}"
}

bootstrap_props=(
  prop_ws_check_workstation_dir
  prop_ws_check_initial_tooling_setup
  prop_ws_check_workstation_repo
)

ensure_props () {
  local initial_props=("$@")
  local props=("${initial_props[@]}")
  local prop_result fix_result
  local current

  while (($#)); do
    local current="$1" prop_result
    shift
    echo "checking: $current..."
    REPLY=()
    prop_result=0
    "$current" || { prop_result="$?"; : ; }
    if (( prop_result == 0 )); then
       echo "checking: $current ... OK"
       if (( ${#REPLY[@]} > 1 )) && [[ "${REPLY[0]}" == "additional_props" ]]; then
         additional_props=("${REPLY[@]:1}")
         REPLY=() # unset to prevent any confusion on next run
         echo  "$current defines additional properties, checking (${additional_props[@]})"
         set "${additional_props[@]}" "$@"
       fi
    else
       echo "checking: $current ... FAIL"
       echo "fixing: $current ..."
       interact "${current}_fix"
       fix_result="$?"
       if (( fix_result == 0 )); then
          echo "fixing: $current .... OK"
          "$current"
          prop_result="$?"
          if (( prop_result == 0 )); then
             echo "checking: $current .... OK"
          else
             echo "checking: $current .... FAIL"
             echo "prop $current still failing after running fix, aborting"
          fi
       else
          echo "fixing: $current .... FAIL"
          echo "error while fixing $current, aborting"
          exit 88
       fi
    fi
  done
}

: "${interact_always_continue:=0}"

interact() {
  local has_continue=0 the_command="$1"

  if [ "$workstation_interactive" != "true" ]; then
    "$the_command";
    return 0;
  fi

  if [ "$interact_always_continue" == "1" ]; then
    has_continue=1
  fi

  while [ "$has_continue" != "1" ]; do
    read -r -e -n 1 -p "About to run '$1', continue? (c/q/!/p/?):" response
    case "$response" in
      c) has_continue=1;;
      q) echo "quitting..."; exit 0;;
      \!) interact_always_continue=1; has_continue=1;;
      p) type "$the_command";;
      ?) interact_help;;
      *) echo "unrecognized response '$response'."
    esac
  done

  # if we're here, we must have gotten continue
  "$the_command"
}

interact_help() {
  echo "c=continue, q=quit, !=always continue, p=print function definition, ?=print this help";
}
