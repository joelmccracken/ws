setup (){
    load 'test_helper/helper'
    _setup_common
    . "$PROJECT_ROOT/ws_tool/ws"
}

@test "supports help flag" {
    run ws -h
    assert_output --partial 'Usage:'
}

@test "process_cli_args parse verbose flag" {
    ws_command_arguments=(args -v bootstrap)
    process_cli_args
    assert_equal "$WORKSTATION_VERBOSE" true
}

@test "process_cli_args parse verbose flag (long)" {
    ws_command_arguments=(args --verbose bootstrap)
    process_cli_args
    assert_equal "$WORKSTATION_VERBOSE" true
}

@test "process_cli_args parse bootstrap subcommand" {
    ws_command_arguments=(args bootstrap)
    process_cli_args
    assert_equal "$ws_command" "bootstrap"
}

@test "process_cli_args parse bootstrap subcommand with name flag short" {
    ws_command_arguments=(args -n glamdring bootstrap)
    process_cli_args
    assert_equal "$ws_command" "bootstrap"
    assert_equal "$workstation_name_arg" "glamdring"
}

@test "process_cli_args parse bootstrap subcommand with workstation name long flag" {
    ws_command_arguments=(args --name aeglos bootstrap )
    process_cli_args
    assert_equal "$ws_command" "bootstrap"
    assert_equal "$workstation_name_arg" "aeglos"
}

@test "process_cli_args parse bootstrap command doctor" {
    ws_command_arguments=(args doctor)
    process_cli_args
    assert_equal "$ws_command" "doctor"
}

# export ws_command_arguments=(args bootstrap glamdring); source ws; process_cli_args; echo $?
