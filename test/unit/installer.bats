#!/usr/bin/env bash

setup (){
    load '../test_helper/helper'
    _setup_common
}

export WS_DIR
@test "runs ws_install" {
    WS_DIR="$(_mktemp "ws-install")"
    set_workstation_version_last_sha

    run ws_install.sh

    assert [ -x "${WS_DIR}/ws" ]
}
