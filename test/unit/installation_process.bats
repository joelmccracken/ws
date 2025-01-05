setup (){
    load '../test_helper/helper'
    _setup_common
}

## bats test_tags=bats:focus
@test "the install script and then run ws bootstrap from this project checkout" {
    WS_CONF="$(_mktemp "ws-config-dir")"
    WS_DIR="$WS_CONF/vendor/ws"

    set_workstation_version_last_sha

    run ws_install.sh
    assert_success
    assert [ -x "$WS_DIR/ws" ]

    # ok, above we demonstrate that the ws_install script in this repo does
    # indeed install the ws executable

    # below we use the stuff from this project checkout however to test it
    # HACK get the tool to actually run code from current local checkout
    ( cd "$PROJECT_ROOT";
      git ls-files | while read -r gitfile; do
          cp -r "$gitfile" "$WS_DIR/$gitfile"
      done;
    )

    local ws_cfg_src
    ws_cfg_src="$(_mktemp "ws-config-src-dir")"
    cat <<-EOF > "$ws_cfg_src/settings.sh"
    export WS_CONF="$WS_CONF"
    export WS_DIR="$PROJECT_ROOT"
    export workstation_names=(workstation_a workstation_b)
EOF

    cat <<-EOF > "$ws_cfg_src/settings.workstation_a.sh"
    WS_NAME=workstation_a
EOF

    cat <<-EOF > "$ws_cfg_src/config.sh"
    workstation_props_workstation_a=()
    workstation_props_workstation_a+=(prop_ws_current_settings_symlink)
EOF

    WS_NAME=workstation_a
    run "$WS_DIR/ws" bootstrap --initial-config-dir "$ws_cfg_src"
    assert_success
}

@test "the install script from curl/github and then run ws bootstrap" {
    WS_CONF="$(_mktemp "ws-config-dir")"
    ws_cfg_src="$(_mktemp "ws-config-src-dir")"
    WS_DIR="$WS_CONF/vendor/ws"
    set_workstation_version_last_sha

    do_ws_install() {
        bash <(curl "https://raw.githubusercontent.com/joelmccracken/ws/${WS_VERSION}/ws_install.sh")
    }
    run do_ws_install

    assert_success
    assert [ -x "$WS_DIR/ws" ]

    cat <<-EOF > "$ws_cfg_src/settings.sh"
    export WS_CONF="$WS_CONF"
    export WS_DIR="$WS_DIR"
EOF

    cat <<-EOF > "$ws_cfg_src/config.sh"
    workstation_names=(workstation_a workstation_b)
EOF
    export WS_NAME=workstation_b
    run "$WS_DIR/ws" bootstrap --initial-config-dir "$ws_cfg_src"

    assert_success
}
