ws_df_dotfiles_fn_name() {
  echo "workstation_props_dotfiles_$WORKSTATION_NAME";
}

prop_ws_df_dotfiles() {
  local fn
  fn="$(ws_df_dotfiles_fn_name)"
  if declare -f "$fn" &> /dev/null; then
    ws_df_dotfile_mode=check
    ws_df_dotfile_run_failure=
    "$fn"
    if [[ -n "$ws_df_dotfile_run_failure" ]]; then
      return 9;
    fi
  else
    echo "warning: no function exists named '$(ws_df_dotfiles_fn_name)', skipping prop" 1>&2;
    return 0;
  fi
}

prop_ws_df_dotfiles_fix() {
  local fn
  fn="$(ws_df_dotfiles_fn_name)"
  if declare -f "$fn" &> /dev/null; then
    ws_df_dotfile_mode=fix
    ws_df_dotfile_run_failure=
    "$fn"
    if [[ -n "$ws_df_dotfile_run_failure" ]]; then
      return 9;
    fi
  else
    echo "warning: no function exists named '$(ws_df_dotfiles_fn_name)', skipping prop" 1>&2;
    return 0;
  fi
}

ws_df_dotfile_src_dir_default() {
  echo "$WORKSTATION_CONFIG_DIR/dotfiles"
}

ws_df_dotfile_dest_dir_default() {
  echo "$HOME"
}

: "${ws_df_dotfile_mode:=check}"
: "${ws_df_dotfile_src_dir:="$(ws_df_dotfile_src_dir_default)"}"
# dest dir config useful for testing
: "${ws_df_dotfile_dest_dir:="$(ws_df_dotfile_dest_dir_default)"}"
: "${ws_df_dotfile_run_failure:=}"

dotfile() {
  local ln_dot= filename=
  while (( $# > 0 )); do
    local current="$1"
    shift;
    case "$current" in
      (--ln-dot) ln_dot=true;;
      (*) filename=$current;;
    esac
  done
  local src="${ws_df_dotfile_src_dir}"
  local dest="${ws_df_dotfile_dest_dir}"

  if [[ -n "$ln_dot" ]]; then
    # note dest filename prefixed with a dot
    dotfile_ln "$src/$filename" "$dest/.$filename"
  fi
}

dotfile_ln(){
  case "$ws_df_dotfile_mode" in
      (check) dotfile_ln_check "$@";;
      (fix) dotfile_ln_fix "$@";;
      (*) echo "ws_df_dotfile_mode unexpected value '$ws_df_dotfile_mode'" 1>&2; exit 1;;
  esac
}

dotfile_ln_check() {
  local src="$1" dest="$2" dest_actual=
  if ! [[ -e "$src" ]]; then
    echo "error: no file found at '$src'" 1>&2;
    ws_df_dotfile_run_failure=true
    return 10;
  fi
  if [[ -L "$dest" ]]; then
    dest_actual="$(readlink -f "$dest")"
    if [[ "$dest_actual" == "$src" ]] ||
         [[ "$dest_actual" == "$(readlink -f "$src")" ]]; then
      # second condition is a mac thing, readlink w a temp dir
      # ends up in "/private..." in a surprising way
      return 0;
    else
      echo "error: expected '$dest' symlink to '$src', actual '$dest_actual'" 1>&2
      ws_df_dotfile_run_failure=true
      return 9;
    fi
  elif ! [[ -e "$dest" ]]; then
    echo "error: '$dest' does not exist (expected symlink to '$src')" 1>&2
    ws_df_dotfile_run_failure=true;
    return 8;
  else
    echo "error: expected '$dest' symlink to '$src', but is normal file" 1>&2
    ws_df_dotfile_run_failure=true;
    return 11;
  fi
}

dotfile_ln_fix() {
  local src="$1" dest="$2" dest_actual=

  if ! [[ -e "$src" ]]; then
    echo "error: no file found at '$src'" 1>&2;
    ws_df_dotfile_run_failure=true
    return 10;
  fi
  if [[ -L "$dest" ]]; then
    dest_actual="$(readlink -f "$dest")"
    if [[ "$dest_actual" == "$src" ]]; then
      return 0;
    fi;
  fi
  if [[ -e "$dest" ]]; then
    local backup=
    backup="$(mv_to_backup "$dest")"
    echo "moving '$dest' to backup at '$backup'"
  fi
  ln -s "$src" "$dest"
}
