#!/usr/bin/env bash
setup (){
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load 'test_helper/helper'

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    PATH="$PROJECT_ROOT:/bin/:$PATH"
    . "$PROJECT_ROOT/lib/tools.bash"
    ws_reset_settings
}

@test "ws_reset_settings works like i think it does" {
    ORIG_WORKSTATION_DIR="$WORKSTATION_DIR"
    WORKSTATION_DIR=poopy
    assert [ "$WORKSTATION_DIR" = "poopy" ]

    ws_reset_settings

    assert [ "$WORKSTATION_DIR" = "$ORIG_WORKSTATION_DIR" ]
}



@test "settings sets appropriate default values" {
    assert_regex "$WORKSTATION_CONFIG_DIR" .*/.config/workstation
    assert_regex "$WORKSTATION_CONFIG_FILE" .*/.config/workstation/config.sh
    assert_regex "$WORKSTATION_SETTINGS_FILE" .*/.config/workstation/settings.sh
    assert_regex "$WORKSTATION_DIR" .*/.config/workstation/src
    assert [ "$WORKSTATION_REPO_GIT_ORIGIN" = 'git@github.com:joelmccracken/workstation.git' ]
    assert [ "$WORKSTATION_VERBOSE" = false ]
    assert [ "$WORKSTATION_LOG_LEVEL" = error ]
}

@test "loading settings honors existing env vars" {
    ws_unset_settings
    WORKSTATION_CONFIG_DIR="/tmp/workstation-dir-$RANDOM"
    WORKSTATION_REPO_GIT_ORIGIN='git@github.com:some-other-user/workstation.git'
    MY_WORKSTATION_REPO_GIT_ORIGIN="$WORKSTATION_REPO_GIT_ORIGIN"
    . "$PROJECT_ROOT/lib/settings.bash"

    assert [ "$WORKSTATION_CONFIG_DIR" = "$WORKSTATION_CONFIG_DIR" ]
    assert [ "$WORKSTATION_CONFIG_FILE" = "$WORKSTATION_CONFIG_DIR/config.sh" ]
    assert [ "$WORKSTATION_SETTINGS_FILE" = "$WORKSTATION_CONFIG_DIR/settings.sh" ]
    assert [ "$WORKSTATION_DIR" = "$WORKSTATION_CONFIG_DIR/src" ]
    assert [ "$WORKSTATION_REPO_GIT_ORIGIN" = "$MY_WORKSTATION_REPO_GIT_ORIGIN" ]
    assert [ "$WORKSTATION_VERBOSE" = false ]
    assert [ "$WORKSTATION_LOG_LEVEL" = error ]
}
