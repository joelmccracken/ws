setup (){
  load "../test_helper/helper"
    _setup_common
    . "$PROJECT_ROOT/ws"
}

@test "supports help flag" {
    run ws -h
    assert_output --partial 'Usage:'
}

@test "ws_cli_proc_args parse verbose flag" {
    ws_cli_proc_args -v bootstrap
    assert_equal "$(ws_lookup WS_VERBOSE)" true
}

@test "ws_cli_proc_args parse verbose flag (long)" {
    ws_cli_proc_args --verbose bootstrap
    assert_equal "$(ws_lookup WS_VERBOSE)" true
}

@test "ws_cli_proc_args parse bootstrap subcommand" {
    ws_cli_proc_args bootstrap
    assert_equal "$ws_cli_arg_cmd" "bootstrap"
}

@test "ws_cli_proc_args parse bootstrap command doctor" {
    ws_cli_proc_args doctor
    assert_equal "$ws_cli_arg_cmd" "doctor"
}

@test "fails with unknown long" {
    run ws_cli_proc_args --foo
    assert_failure
    assert_output --partial "unknown argument '--foo'"
}

@test "fails with unknown short" {
    run ws_cli_proc_args -z
    assert_failure
    assert_output --partial "ws: argument parsing: unknown argument '-z'"
}

