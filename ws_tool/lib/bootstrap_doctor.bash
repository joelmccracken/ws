#!/usr/bin/env bash

# bootstrapping and doctoring is closely related enough for now
# decide to keep these in the same file.

prop_ws_settings_file_check() {
   if [[ -f "$WORKSTATION_SETTINGS_FILE" ]] ; then
      echo "settings file exists";
   else
      echo "no settings file found (expected at $WORKSTATION_SETTINGS_FILE)" 2>&1
   fi
}

prop_ws_settings_file_fix() {
   if [[ -f "$WORKSTATION_SETTINGS_FILE" ]] ; then
      echo "settings file exists";
   else
      echo "no settings file found (expected at $WORKSTATION_SETTINGS_FILE)" 2>&1
   fi
}

prop_ws_check_workstation_dir() {
  if [ -d "$WORKSTATION_DIR" ]; then
    echo "WORKSTATION_DIR exists"
    if [ -x "$WORKSTATION_DIR/ws_tool/ws" ]; then
      echo "WORKSTATION_DIR contains ws executable"
      return 0
    else
      echo "$WORKSTATION_DIR does not contain the ws tool" 1>&2
      return 2
    fi
  else
    echo "$WORKSTATION_DIR (WORKSTATION_DIR) is absent" 1>&2
    echo "(is workstation installed to a custom location? set WORKSTATION_DIR=path/to/workstation)" 1>&2
    return 1
  fi
}

prop_ws_check_workstation_dir_fix() {
  # TODO this is basically a copy/paste of ws_install.sh
  # somehow figure out another way to do this?
  TMPDIR=$(mktemp -d "/tmp/ws-install-XXXXXX")

  # installer of ws tool/project
  cd "$TMPDIR"
  curl -L https://github.com/joelmccracken/workstation/archive/${WORKSTATION_VERSION}.tar.gz | tar zx

  mkdir -p "$WORKSTATION_DIR"
  mv "${TMPDIR}"/workstation-*/{,.[^.]}* "$WORKSTATION_DIR"
}

prop_ws_check_workstation_repo() {
  if [ -d "$WORKSTATION_DIR/.git" ]; then
    echo "WORKSTATION_DIR git directory exists"
    return 0
  else
    echo "$WORKSTATION_DIR/.git directory is absent" 1>&2
    return 1
  fi
}

prop_ws_check_workstation_repo_fix() {
  cd "$WORKSTATION_DIR"
  git init .
  git remote add origin "$WORKSTATION_REPO_GIT_ORIGIN"
  git fetch
  git reset --mixed "origin/$WORKSTATION_VERSION"
}

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
  echo "bootstrapping '$WORKSTATION_NAME'"



  ensure_props "${bootstrap_props[@]}"
}

bootstrap_props=(
  prop_ws_check_workstation_dir
  prop_ws_check_workstation_repo
)

ensure_props () {
  local props=("$@")
  local prop_results
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
       "${current}_fix"
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
