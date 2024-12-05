setup (){
    load 'test_helper/helper'
    _setup_common
    source "$PROJECT_ROOT/ws_tool/ws"
}




@test "supports help flag" {
    run ws -h
    assert_output --partial 'Usage:'
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

@test "process_cli_args parse bootstrap subcommand with name flag short" {
    WS_COMMAND_ARGUMENTS=(-n glamdring bootstrap)
    process_cli_args
    assert_equal "$WS_COMMAND" "bootstrap"
    assert_equal "$WORKSTATION_NAME_ARG" "glamdring"
}

@test "process_cli_args parse bootstrap subcommand with workstation name long flag" {
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

@test "process_cli_args parses the workstation name overriding current" {
    export WORKSTATION_NAME=goofy
    WS_COMMAND_ARGUMENTS=(-n foofy)
    process_cli_args
    assert_equal "$WORKSTATION_NAME" foofy
}

# export WS_COMMAND_ARGUMENTS=(bootstrap glamdring); source ws; process_cli_args; echo $?
