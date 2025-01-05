ws_prop_df__dotfile_fn_name() {
  local wsn
  wsn="$(ws_lookup WS_NAME)"
  echo "workstation_props_dotfiles_$wsn";
}

ws_prop_df_dotfiles() {
  local fn
  fn="$(ws_prop_df__dotfile_fn_name)"
  if declare -f "$fn" &> /dev/null; then
    ws_prop_df_run_current_mode=check
    ws_prop_df__run_failure=
    "$fn"
    if [[ -n "$ws_prop_df__run_failure" ]]; then
      return 9;
    fi
  else
    echo "warning: no function exists named '$fn', skipping prop" 1>&2;
    return 0;
  fi
}

ws_prop_df_dotfiles_fix() {
  local fn
  fn="$(ws_prop_df__dotfile_fn_name)"
  if declare -f "$fn" &> /dev/null; then
    ws_prop_df_run_current_mode=fix
    ws_prop_df__run_failure=
    "$fn"
    if [[ -n "$ws_prop_df__run_failure" ]]; then
      return 9;
    fi
  else
    echo "warning: no function exists named '$fn', skipping prop" 1>&2;
    return 0;
  fi
}

WS_PROP_DF_SRC_DIR__default() {
  echo "$(ws_lookup WS_CONF)/dotfiles"
}

ws_prop_df__dotfile_dest_dir_default() {
  echo "$HOME"
}

: "${WS_PROP_DF_SRC_DIR:=}"

# dest dir config useful for testing, not intended for use
: "${ws_prop_df__dotfile_dest_dir:="$(ws_prop_df__dotfile_dest_dir_default)"}"
: "${ws_prop_df__run_failure:=}"
: "${ws_prop_df_run_current_mode:=check}"
dotfile() {
  local dot= filename= ln= dir= src= dest=
  while (( $# > 0 )); do
    local current="$1"
    shift;
    case "$current" in
      (--dot) dot=true;;
      (--ln) ln=true;;
      (--dir) dir=true;;
      (*) filename=$current;;
    esac
  done
  src="$(ws_lookup WS_PROP_DF_SRC_DIR)"
  dest="${ws_prop_df__dotfile_dest_dir}"

  if [[ -n "$ln" ]] ; then
    local pfx=""
    if [[ -n "$dot" ]]; then
      pfx="."
    fi
    dest_full="${dest}/${pfx}${filename}"
    if [[ -n "$dir" ]]; then
      dotfile_dir "$dest_full"
    fi
    dotfile_ln "$src/$filename" "$dest_full"
  fi
}

dotfile_ln(){
  case "$ws_prop_df_run_current_mode" in
    (check) dotfile_ln_check "$@";;
    (fix) dotfile_ln_fix "$@";;
    (*) echo "ws_prop_df_run_current_mode unexpected value '$ws_prop_df_run_current_mode'" 1>&2; exit 1;;
  esac
}

dotfile_ln_check() {
  local src="$1" dest="$2" dest_actual=
  if ! [[ -e "$src" ]]; then
    echo "error: no file found at '$src'" 1>&2;
    ws_prop_df__run_failure=true
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
      ws_prop_df__run_failure=true
      return 9;
    fi
  elif ! [[ -e "$dest" ]]; then
    echo "error: '$dest' does not exist (expected symlink to '$src')" 1>&2
    ws_prop_df__run_failure=true;
    return 8;
  else
    echo "error: expected '$dest' symlink to '$src', but is normal file" 1>&2
    ws_prop_df__run_failure=true;
    return 11;
  fi
}

dotfile_ln_fix() {
  local src="$1" dest="$2" dest_actual=

  if ! [[ -e "$src" ]]; then
    echo "error: no file found at '$src'" 1>&2;
    ws_prop_df__run_failure=true
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

dotfile_dir() {
  case "$ws_prop_df_run_current_mode" in
    (check) dotfile_dir_check "$@";;
    (fix) dotfile_dir_fix "$@";;
    (*) echo "ws_prop_df_run_current_mode unexpected value '$ws_prop_df_run_current_mode'" 1>&2; exit 1;;
  esac
}

dotfile_dir_check() {
  local dest_full="$1" dest_dir
  dest_dir="$(dirname "$dest_full")"
  if ! [[ -e "$dest_dir" ]]; then
    echo "no directory exists at '$dest_dir'" 1>&2
    ws_prop_df__run_failure=true
    return 8;
  fi
}

dotfile_dir_fix() {
  local dest_full="$1" dest_dir
  dest_dir="$(dirname "$dest_full")"
  if ! [[ -e "$dest_dir" ]]; then
    echo "creating directory '$dest_dir'" 1>&2
    mkdir -p "$dest_dir"
  fi
}
