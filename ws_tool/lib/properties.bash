#!/usr/bin/env bash

. "$WORKSTATION_DIR/ws_tool/lib/lib.bash"


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
# setting the __ret global to an array where the first argument is
# "additional_props" and subsequent arguments are those properties. for example,
# say above property foo should have other props bar and baz, then the following
# value would be appropriate:
#   __ret=(additional_props prop_bar prop_baz)
# after prop foo returns with a zero exit code, these props are handled next.
# By default, prop_foo would not be checked again after the other props are fulfilled, but
# you could make it do this by for example
#   prop_foo() {
#    __ret=(additional_props prop_bar prop_baz prop_foo)
#   }
# Note that prop_foo is included at the end of the additional properties list.
# Of course, you wouldn't want this exact example, otherwise it would imply
# that foo would be checked again and again, ad infinitum.

prop_ws_settings_file_check() {
   if [[ -f "$WORKSTATION_SETTINGS_FILE" ]]; then
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

prop_ws_check_has_git() {
    if which git > /dev/null; then
        echo "git is detected"
    else
        echo "no git is detected"
    fi
}

prop_ws_check_has_git_fix() {
    if is_mac; then
        echo "git is detected"
    else
        echo "no git is detected"
    fi
}

prop_ws_check_initial_tooling_setup()
{
    if is_mac; then
        __ret=(additional_props prop_ws_check_mac_initial_setup)
        return 0
    else
        if is_linux; then
            __ret=(additional_props prop_ws_check_linux_initial_setup)
            return 0
        else
            error "unable to determine workstation system type (mac, linux)"
            return 1
        fi
    fi
}

# check to ensure that xcode cli tools are installed
# this command will tell without itself trying to install them
prop_ws_check_mac_initial_setup () {
    pkgutil --pkg-info=com.apple.pkg.CLTools_Executables
}

prop_ws_check_mac_initial_setup_fix () {
    sudo bash -c '(xcodebuild -license accept; xcode-select --install) || exit 0'
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
