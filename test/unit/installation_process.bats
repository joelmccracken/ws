#!/usr/bin/env zsh

setup (){
    load '../test_helper/helper'
    _setup_common
}

@test "the install script and then run ws bootstrap from this project checkout" {
    export WORKSTATION_CONFIG_DIR="$(_mktemp "ws-config-dir")"
    export WORKSTATION_CONFIG_SRC_DIR="$(_mktemp "ws-config-src-dir")"
    export WORKSTATION_DIR="$(ws_lookup WORKSTATION_CONFIG_DIR)/vendor/ws"

    set_workstation_version_last_sha

    run ws_install.sh
    assert_success
    assert [ -x "$(ws_lookup WORKSTATION_DIR)/ws" ]

    # ok, above we demonstrate that the ws_install script in this repo does
    # indeed install the ws executable

    # below we use the stuff from this project checkout however to test it
    # HACK get the tool to actually run code from current local checkout
    ( cd "$PROJECT_ROOT";
      git ls-files | while read -r gitfile; do
          cp -r "$gitfile" "$(ws_lookup WORKSTATION_DIR)/$gitfile"
      done;
    )

    cat <<-EOF > "$(ws_lookup WORKSTATION_CONFIG_SRC_DIR)/settings.sh"
    export WORKSTATION_CONFIG_DIR="$(ws_lookup WORKSTATION_CONFIG_DIR)"
    export WORKSTATION_DIR="$PROJECT_ROOT"
    export workstation_names=(workstation_a workstation_b)
EOF

    cat <<-EOF > "$(ws_lookup WORKSTATION_CONFIG_SRC_DIR)/settings.workstation_a.sh"
    WORKSTATION_NAME=workstation_a
EOF

    cat <<-EOF > "$(ws_lookup WORKSTATION_CONFIG_SRC_DIR)/config.sh"
    workstation_props_workstation_a=()
    workstation_props_workstation_a+=(prop_ws_current_settings_symlink)
EOF

    export WORKSTATION_NAME=workstation_a
    WORKSTATION_DIR="$(ws_lookup WORKSTATION_DIR)"
    WORKSTATION_CONFIG_DIR="$(ws_lookup WORKSTATION_CONFIG_DIR)"
    run env "$(ws_lookup WORKSTATION_DIR)/ws" bootstrap --initial-config-dir "$(ws_lookup WORKSTATION_CONFIG_SRC_DIR)"
    assert_success
}

@test "the install script from curl/github and then run ws bootstrap" {
    export WORKSTATION_CONFIG_DIR="$(_mktemp "ws-config-dir")"
    export WORKSTATION_CONFIG_SRC_DIR="$(_mktemp "ws-config-src-dir")"
    export WORKSTATION_DIR="$(ws_lookup WORKSTATION_CONFIG_DIR)/vendor/ws"
    set_workstation_version_last_sha

    do_ws_install() {
        bash <(curl "https://raw.githubusercontent.com/joelmccracken/ws/${WORKSTATION_VERSION}/ws_install.sh")
    }
    run do_ws_install

    assert_success
    assert [ -x "$(ws_lookup WORKSTATION_DIR)/ws" ]

    cat <<-EOF > "$(ws_lookup WORKSTATION_CONFIG_SRC_DIR)/settings.sh"
    export WORKSTATION_CONFIG_DIR="$(ws_lookup WORKSTATION_CONFIG_DIR)"
    export WORKSTATION_DIR="$(ws_lookup WORKSTATION_DIR)"
EOF

    cat <<-EOF > "$(ws_lookup WORKSTATION_CONFIG_SRC_DIR)/config.sh"
    workstation_names=(workstation_a workstation_b)
EOF
    export WORKSTATION_NAME=workstation_b
    run env WORKSTATION_DIR="$(ws_lookup WORKSTATION_DIR)" \
        WORKSTATION_NAME=workstation_b \
        WORKSTATION_CONFIG_DIR="$(ws_lookup WORKSTATION_CONFIG_DIR)" \
        "$(ws_lookup WORKSTATION_DIR)/ws" bootstrap --initial-config-dir "$(ws_lookup WORKSTATION_CONFIG_SRC_DIR)"

    assert_success
}
