ws_df_dotfiles_fn_name() {
  echo "workstation_props_dotfiles_$WORKSTATION_NAME";
}

prop_ws_df_dotfiles() {
  if declare -f "$(ws_df_dotfiles_fn_name)" &> /dev/null; then
    echo "run each checking how its set up"
  else
    echo "warning: no function exists named '$(ws_df_dotfiles_fn_name)', skipping prop" 1>&2;
    return 0;
  fi
}

prop_ws_df_dotfiles_fix() {
echo foo
}
