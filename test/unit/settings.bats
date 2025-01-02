#!/usr/bin/env bash
setup (){
    load '../test_helper/helper'
    _setup_common
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
    assert_regex "$WORKSTATION_DIR" .*/.config/workstation/vendor/ws
    assert [ "$WORKSTATION_REPO_GIT_ORIGIN" = 'https://github.com/joelmccracken/ws.git' ]
    assert [ "$WORKSTATION_VERBOSE" = false ]
    assert [ "$WORKSTATION_LOG_LEVEL" = error ]
}

@test "loading settings honors existing env vars" {
    ws_unset_settings
    WORKSTATION_CONFIG_DIR="$(_mktemp "ws-config-dir")"
    WORKSTATION_REPO_GIT_ORIGIN='git@github.com:some-other-user/workstation.git'
    MY_WORKSTATION_REPO_GIT_ORIGIN="$WORKSTATION_REPO_GIT_ORIGIN"
    . "$PROJECT_ROOT/lib/settings.bash"

    assert [ "$WORKSTATION_CONFIG_DIR" = "$WORKSTATION_CONFIG_DIR" ]
    assert [ "$WORKSTATION_DIR" = "$WORKSTATION_CONFIG_DIR/vendor/ws" ]
    assert [ "$WORKSTATION_REPO_GIT_ORIGIN" = "$MY_WORKSTATION_REPO_GIT_ORIGIN" ]
    assert [ "$WORKSTATION_VERBOSE" = false ]
    assert [ "$WORKSTATION_LOG_LEVEL" = error ]
}

@test "ws_lookup prevents 'sandbox' violations" {
    ws_unset_settings

    WORKSTATION_CONFIG_DIR="$BATS_WS_USER_HOME/.config/workstation"
    run ws_lookup WORKSTATION_CONFIG_DIR
    assert_failure
    assert_output --partial "error: test isolation violation: 'WORKSTATION_CONFIG_DIR' has value '$WORKSTATION_CONFIG_DIR'"
}

## bats test_tags=bats:focus
@test "ws_lookup 'sandbox' volation check be disabled" {
    ws_unset_settings

    WORKSTATION_CONFIG_DIR="$BATS_WS_USER_HOME/.config/workstation"
    run ws_lookup --no-test-sandbox WORKSTATION_CONFIG_DIR
    assert_success
    assert_output --partial "$WORKSTATION_CONFIG_DIR"
}

@test "ws_lookup will set with default if available" {
    ws_unset_settings

    WS_SOME_NEW_SETTING=
    WS_SOME_NEW_SETTING__default() {
      echo -n "hello clarice"
    }

    run ws_lookup WS_SOME_NEW_SETTING
    assert_output "hello clarice"
    assert_success
}

# @test "setting accessor errors if home dir is referenced " {
#     ws_unset_settings
#     ws_setting
#     WORKSTATION_CONFIG_DIR="$(_mktemp "ws-config-dir")"
#     WORKSTATION_REPO_GIT_ORIGIN='git@github.com:some-other-user/workstation.git'
#     MY_WORKSTATION_REPO_GIT_ORIGIN="$WORKSTATION_REPO_GIT_ORIGIN"
#     . "$PROJECT_ROOT/lib/settings.bash"

#     assert [ "$WORKSTATION_CONFIG_DIR" = "$WORKSTATION_CONFIG_DIR" ]
#     assert [ "$WORKSTATION_DIR" = "$WORKSTATION_CONFIG_DIR/vendor/ws" ]
#     assert [ "$WORKSTATION_REPO_GIT_ORIGIN" = "$MY_WORKSTATION_REPO_GIT_ORIGIN" ]
#     assert [ "$WORKSTATION_VERBOSE" = false ]
#     assert [ "$WORKSTATION_LOG_LEVEL" = error ]
# }
