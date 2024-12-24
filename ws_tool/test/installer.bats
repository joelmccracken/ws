#!/usr/bin/env bash

setup (){
    load 'test_helper/helper'
    _setup_common
}

@test "runs ws_install" {
    export WORKSTATION_DIR="$(mktemp -d "/tmp/ws-dir-XXXXXX")"
    export WORKSTATION_VERSION=workcomp
    # export TO_WORKSTATION_DIR="${TMPDIR}/workstation"
    run ws_install.sh
    assert [ -x "${WORKSTATION_DIR}/ws_tool/ws" ]
}