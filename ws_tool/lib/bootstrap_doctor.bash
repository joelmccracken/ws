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
    return 0
  else
    error "$WORKSTATION_DIR (WORKSTATION_DIR) is absent" 1>&2
    error "(is workstation installed to a custom location? set WORKSTATION_DIR=path/to/workstation)" 1>&2
    return 1
  fi
}

prop_ws_check_workstation_dir_fix() {
  if ! prop_ws_check_workstation_dir > /dev/null 2>&1; then
    # TODO this is basically a copy/paste of ws_install.sh
    # somehow figure out another way to do this?
    : "${WORKSTATION_VERSION:=refs/heads/master}"
    TMPDIR=$(mktemp -d "/tmp/ws-install-XXXXXX")

    # installer of ws tool/project
    cd "$TMPDIR"
    curl -L https://github.com/joelmccracken/workstation/archive/${WORKSTATION_VERSION}.tar.gz | tar zx

    mkdir -p "$WORKSTATION_DIR"
    cd "$WORKSTATION_DIR"

    mv "${TMPDIR}"/workstation-* "$WORKSTATION_DIR/src"
  fi
}

prop_ws_check_workstation_repo() {
  if [ -d "$WORKSTATION_DIR/src/.git" ]; then
    echo "WORKSTATION_DIR git directory exists"
    return 0
  else
    error "$WORKSTATION_DIR/src/.git directory is absent" 1>&2
    return 1
  fi
}

prop_ws_check_workstation_repo_fix() {
  cd "$WORKSTATION_DIR"
  git init .
  git remote add origin $REPO
  git fetch
  git reset --mixed origin/master
}




doctor_command() {
  echo "doctor!";
  prop_ws_check_workstation_dir
  prop_ws_settings_file_check
}

bootstrap_command_setup() {
  if [[ -f "$WORKSTATION_SETTINGS_FILE" ]] ; then
      info "settings file exists, loading it";
      source "$WORKSTATION_SETTINGS_FILE";

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
  echo BOOTSTRAP HERE:
  prop_ws_check_workstation_dir
}
