#!/usr/bin/env zsh

setup (){
    load 'test_helper/helper'
    _setup_common
}

@test "the install script and then run ws bootstrap from this project checkout" {
    export WORKSTATION_CONFIG_DIR="$(mktemp -d "/tmp/ws-config-dir-XXXXXX")"
    export WORKSTATION_DIR="${WORKSTATION_CONFIG_DIR}/src"
    export WORKSTATION_VERSION=workcomp

    run ws_install.sh
    assert [ -x "${WORKSTATION_DIR}/ws_tool/ws" ]

    # ok, above we demonstrate that the ws_install script in this repo does
    # indeed install the ws executable

    # below we use the stuff from this project checkout however to test it
    # HACK get the tool to actually run code from current local checkout
    export WORKSTATION_DIR="${PROJECT_ROOT}"

    cat <<-EOF > "${WORKSTATION_CONFIG_DIR}/settings.sh"
    export WORKSTATION_CONFIG_DIR="$WORKSTATION_CONFIG_DIR"
    export WORKSTATION_DIR="$PROJECT_ROOT"
EOF

    cat <<-EOF > "${WORKSTATION_CONFIG_DIR}/config.sh"
    export workstation_names=(workstation_a workstation_b)
EOF
    export WORKSTATION_NAME=workstation_a
    run "${WORKSTATION_DIR}/ws_tool/ws" bootstrap
    dump_output
    assert_success
}

# @test "the install script and then run ws bootstrap fresh dirs" {
#     export WORKSTATION_CONFIG_DIR="$(mktemp -d "/tmp/ws-config-dir-XXXXXX")"
#     export WORKSTATION_DIR="${WORKSTATION_CONFIG_DIR}/src"
#     export WORKSTATION_VERSION=workcomp

#     cd "$(mktemp -d "/tmp/ws-installer-dl-dir-XXXXXX")"

#     do_ws_install() {
#         bash <(curl "https://raw.githubusercontent.com/joelmccracken/workstation/refs/heads/${WORKSTATION_VERSION}/ws_tool/ws_install.sh")
#     }
#     run do_ws_install

#     assert_success
#     assert [ -x "${WORKSTATION_DIR}/ws_tool/ws" ]

#     cat <<-EOF > "${WORKSTATION_CONFIG_DIR}/settings.sh"
#     export WORKSTATION_CONFIG_DIR="$WORKSTATION_CONFIG_DIR"
#     export WORKSTATION_DIR="$WORKSTATION_DIR"
# EOF

#     cat <<-EOF > "${WORKSTATION_CONFIG_DIR}/config.sh"
#     workstation_names=(workstation-a workstation-b)
# EOF

#     run "${WORKSTATION_DIR}/ws_tool/ws" bootstrap

#     assert_success
# }
