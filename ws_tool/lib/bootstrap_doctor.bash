#!/usr/bin/env bash

# bootstrapping and doctoring is closely related enough for now
# decide to keep these in the same file.

props_ws_settings_file_check() {
   if [[ -f "$WORKSTATION_SETTINGS_FILE" ]] ; then
      echo "settings file exists";
   else
      echo "no settings file found (expected at $WORKSTATION_SETTINGS_FILE)" 2>&1
   fi
}

props_ws_settings_file_fix() {
   if [[ -f "$WORKSTATION_SETTINGS_FILE" ]] ; then
      echo "settings file exists";
   else
      echo "no settings file found (expected at $WORKSTATION_SETTINGS_FILE)" 2>&1
   fi
}

props_ws_check_workstation_dir() {
  if [ -d "$WORKSTATION_DIR" ]; then
    echo "WORKSTATION_DIR exists"
    return 0
  else
    error "$WORKSTATION_DIR (WORKSTATION_DIR) is absent" 1>&2
    error "(is workstation installed to a custom location? set WORKSTATION_DIR=path/to/workstation)" 1>&2
    return 1
  fi
}

props_ws_check_workstation_dir_fix() {
  if ! props_ws_check_workstation_dir > /dev/null 2>&1; then
    # TODO this is basically a copy/paste of ws_install.sh
    # somehow figure out another way to do this?
    : "${WORKSTATION_VERSION:=refs/heads/master}"
    TMPDIR=$(mktemp -d "/tmp/ws-install-XXXXXX")

    # installer of ws tool/project
    cd "$TMPDIR"
    curl -L https://github.com/joelmccracken/workstation/archive/${WORKSTATION_VERSION}.tar.gz | tar zx

    mkdir -p "$WORKSTATION_DIR"
    cd "$WORKSTATION_DIR"

    for f in ${TMPDIR}/workstation-*/* ${TMPDIR}/workstation-*/.*; do
        mv "$f" . ;
    done
  fi
}

prop_ws_check_workstation_repo() {
  if [ -d "$WORKSTATION_DIR/.git" ]; then
    echo "WORKSTATION_DIR git directory exists"
    return 0
  else
    error "$WORKSTATION_DIR/.git directory is absent" 1>&2
    return 1
  fi
}

doctor_command() {
  echo "doctor!";
  props_ws_check_workstation_dir
  props_ws_settings_file_check
}
