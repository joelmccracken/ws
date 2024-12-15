#!/usr/bin/env bash

# bootstrapping and doctoring is closely related enough for now
# decide to keep these in the same file.


doctor_command() {
  echo "doctor!";
  prop_ws_check_workstation_dir
  prop_ws_settings_file_check
}

bootstrap_command_setup() {
  if [[ -f "$WORKSTATION_SETTINGS_FILE" ]] ; then
      info "settings file exists, loading it";
      . "$WORKSTATION_SETTINGS_FILE";

      if [ -z "$WORKSTATION_NAME" ]; then
          echo "settings file loaded, but WORKSTATION_NAME not set."
      fi

      if [[ -z "$WORKSTATION_NAME" && -z "$WORKSTATION_NAME_ARG" ]]; then
          echo "workstation name unset in settings file and not provided as argument."
          echo "must provide -n or --name with workstation name."
          print_workstation_names
          usage_and_quit 1
      fi
  else
     echo "settings file does not exist"
     if [[ -z "$WORKSTATION_NAME" && -z "$WORKSTATION_NAME_ARG" ]]; then
          echo "workstation name is unset."
          echo "must provide -n or --name with workstation name."
          print_workstation_names
          usage_and_quit 1
      fi
  fi
}

bootstrap_command() {
  echo "bootstrapping base properties"

  ensure_props "${bootstrap_props[@]}"

  echo "bootstrapping workstation properties for ${WORKSTATION_NAME}"
}

bootstrap_props=(
  prop_ws_check_workstation_dir
  prop_ws_check_has_git
  prop_ws_check_workstation_repo
)

ensure_props () {
  local props=("$@")
  local prop_result fix_result
  local i
  for ((i=0;i < ${#props[@]}; i++)); do
    local current="${props[i]}"
    echo "checking: $current..."
    "$current"
    prop_result="$?"
    if (( prop_result == 0 )); then
       echo "checking: $current ... OK"
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

  if [ "$WORKSTATION_INTERACTIVE" != "true" ]; then
    "$the_command";
    return 0;
  fi

  if [ "$interact_always_continue" == "1" ]; then
    has_continue=1
  fi

  while [ "$has_continue" != "1" ]; do
    read -e -n 1 -p "About to run '$1', continue? (c/q/!/p/?):" response
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
