#!/usr/bin/env bash
setup (){
    load '../test_helper/helper'
    _setup_common
    ws_reset_settings
}

@test "ws_reset_settings works like i think it does" {
    ORIG_WS_DIR="$(ws_lookup WS_DIR)"
    WS_DIR=poopy
    assert [ "$WS_DIR" = "poopy" ]

    ws_reset_settings

    assert [ "$(ws_lookup WS_DIR)" = "$ORIG_WS_DIR" ]
}

@test "settings sets appropriate default values" {
    assert_regex "$(ws_lookup WS_CONFIG)" .*/.config/workstation
    assert_regex "$(ws_lookup WS_DIR)" .*/.local/share/ws
    assert [ "$(ws_lookup WS_REPO_ORIGIN)" = 'https://github.com/joelmccracken/ws.git' ]
    assert [ "$(ws_lookup WS_VERBOSE)" = false ]
    assert [ "$(ws_lookup WS_LOG_LEVEL)" = error ]
}

@test "loading settings honors existing env vars" {
    ws_unset_settings
    WS_CONFIG="$(tmp "ws-config-dir")"
    # echo "$WS_CONFIG" 1>&3
    WS_REPO_ORIGIN='git@github.com:some-other-user/workstation.git'
    MY_WS_REPO_ORIGIN="$WS_REPO_ORIGIN"
    . "$PROJECT_ROOT/lib/settings.bash"

    assert [ "$(ws_lookup WS_CONFIG)" = "$WS_CONFIG" ]
    assert [ "$(ws_lookup WS_DIR)" = "$HOME/.local/share/ws" ]
    assert [ "$(ws_lookup WS_REPO_ORIGIN)" = "$MY_WS_REPO_ORIGIN" ]
    assert [ "$(ws_lookup WS_VERBOSE)" = false ]
    assert [ "$(ws_lookup WS_LOG_LEVEL)" = error ]
}

@test "ws_lookup prevents 'sandbox' violations" {
    ws_unset_settings

    WS_CONFIG="$BATS_WS_USER_HOME/.config/workstation"
    run ws_lookup WS_CONFIG
    assert_failure
    assert_output --partial "error: test isolation violation: 'WS_CONFIG' has value '$WS_CONFIG'"
}

## bats test_tags=bats:focus
@test "ws_lookup 'sandbox' volation check be disabled" {
    ws_unset_settings

    WS_CONFIG="$BATS_WS_USER_HOME/.config/workstation"
    run ws_lookup --no-test-sandbox WS_CONFIG
    assert_success
    assert_output --partial "$WS_CONFIG"
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
#     WS_CONFIG="$(_mktemp "ws-config-dir")"
#     WS_REPO_ORIGIN='git@github.com:some-other-user/workstation.git'
#     MY_WS_REPO_ORIGIN="$WS_REPO_ORIGIN"
#     . "$PROJECT_ROOT/lib/settings.bash"

#     assert [ "$WS_CONFIG" = "$WS_CONFIG" ]
#     assert [ "$WS_DIR" = "$HOME/.local/share/ws" ]
#     assert [ "$WS_REPO_ORIGIN" = "$MY_WS_REPO_ORIGIN" ]
#     assert [ "$WS_VERBOSE" = false ]
#     assert [ "$WS_LOG_LEVEL" = error ]
# }
