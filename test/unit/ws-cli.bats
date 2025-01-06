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
    assert_equal "$ws_command" "bootstrap"
}

@test "ws_cli_proc_args parse bootstrap subcommand with name flag short" {
    ws_cli_proc_args -n glamdring bootstrap
    assert_equal "$ws_command" "bootstrap"
    assert_equal "$ws_cli_arg_ws_name" "glamdring"
}

@test "ws_cli_proc_args parse bootstrap subcommand with workstation name long flag" {
    ws_cli_proc_args --name aeglos bootstrap
    assert_equal "$ws_command" "bootstrap"
    assert_equal "$ws_cli_arg_ws_name" "aeglos"
}

@test "ws_cli_proc_args parse bootstrap command doctor" {
    ws_cli_proc_args doctor
    assert_equal "$ws_command" "doctor"
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

@test "parses args for initial config w a repo" {
   ws_cli_proc_args \
       --initial-config-repo 'git@github.com:whatever/foo.git' \
       --initial-config-repo-ref 'master'

   assert_equal "$ws_cli_arg_initial_config_repo" 'git@github.com:whatever/foo.git'
   assert_equal "$ws_cli_arg_initial_config_repo_ref" 'master'

}
