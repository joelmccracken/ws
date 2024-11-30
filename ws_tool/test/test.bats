setup (){
    load 'test_helper/helper'
    _setup_common
    source "$PROJECT_ROOT/ws"
}

@test "supports help flag" {
    run ws -h
    assert_output --partial 'ws usage:'
}

@test "process_cli_args parse verbose flag" {
    WS_COMMAND_ARGUMENTS=(-v bootstrap)
    process_cli_args
    assert_equal "$WORKSTATION_VERBOSE" true
}

@test "process_cli_args parse verbose flag (long)" {
    WS_COMMAND_ARGUMENTS=(--verbose bootstrap)
    process_cli_args
    assert_equal "$WORKSTATION_VERBOSE" true
}

@test "process_cli_args parse bootstrap subcommand" {
    WS_COMMAND_ARGUMENTS=(bootstrap)
    process_cli_args
    assert_equal "$WS_COMMAND" "bootstrap"
}

@test "process_cli_args parse bootstrap subcommand with workstation name pos param" {
    WS_COMMAND_ARGUMENTS=(bootstrap glamdring)
    process_cli_args
    assert_equal "$WS_COMMAND" "bootstrap"
    assert_equal "$WORKSTATION_NAME_ARG" "glamdring"
}

@test "process_cli_args parse bootstrap subcommand with workstation name flag" {
    WS_COMMAND_ARGUMENTS=(--name aeglos bootstrap )
    process_cli_args
    assert_equal "$WS_COMMAND" "bootstrap"
    assert_equal "$WORKSTATION_NAME_ARG" "aeglos"
}

@test "process_cli_args parse bootstrap command doctor" {
    WS_COMMAND_ARGUMENTS=(doctor)
    process_cli_args
    assert_equal "$WS_COMMAND" "doctor"
}

# export WS_COMMAND_ARGUMENTS=(bootstrap glamdring); source ws; process_cli_args; echo $?
