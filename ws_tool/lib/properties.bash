#!/usr/bin/env bash

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
