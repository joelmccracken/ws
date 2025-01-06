############
## property: dotfiles setup
##
## ensures dotfiles are as defined
## context: I tried the various dotfiles systems out there
## and none of them did what I wanted or needed them to do.
##
## Dotfiles as a thing to automate is a bit tricky for various reasons:
## - symlinks for dotfiles works well, except some tools ignore symlinks
##   and only work with actual files in the expected location.
##   - So only real appropriate solution is to either have the VC directly in
##     the $HOME, or to do appropriate manual syncing and state checking.
## - while the actual file/symlink/etc actually in home dir may to start with
##   a dot, there is no need for the files in the vc repo to be so named.
## - I may want to vc the files etc in ~/.config/git and ~/.config/doom, I
##   explicitly do _not_ want to also store the files in ~/.config/emacs.
##   Hence, special logic is needed to deal with subdirectorys in dotfiles.
## - I know I've run across others, though they escape me now. Hopefully I
##   remember to add to this list in the future.
##
## The primary mechanism for this property is
## - an expected directory where the various dotfiles will reside
##   (by default, $WS_CONFIG/dotfiles)
## - a function (keyed by workstation name) that specifies what
##   should be done with the files in this dir. See example for how this works.

ws_prop_df_dotfiles() {
  local fn
  fn="$(ws_df__dotfile_fn_name)"
  if declare -f "$fn" &> /dev/null; then
    ws_df__prop_run_current_mode=check
    ws_df__prop_run_failure=
    "$fn"
    if [[ -n "$ws_df__prop_run_failure" ]]; then
      return 9;
    fi
  else
    echo "warning: no function exists named '$fn', skipping prop" 1>&2;
    return 0;
  fi
}

ws_prop_df_dotfiles_fix() {
  local fn
  fn="$(ws_df__dotfile_fn_name)"
  if declare -f "$fn" &> /dev/null; then
    ws_df__prop_run_current_mode=fix
    ws_df__prop_run_failure=
    "$fn"
    if [[ -n "$ws_df__prop_run_failure" ]]; then
      return 9;
    fi
  else
    echo "warning: no function exists named '$fn', skipping prop" 1>&2;
    return 0;
  fi
}

## Configuration option:
## param name:  WS_PROP_DF_SRC_DIR
## description: the location to find the source dotfiles
## default:     $WS_CONFIG/dotfiles

: "${WS_PROP_DF_SRC_DIR:=}"

WS_PROP_DF_SRC_DIR__default() {
  echo "$(ws_lookup WS_CONFIG)/dotfiles"
}


## writing the dotfiles spec function
## uses a verbose/namespace fn name, if annoying
## when specifying dots, should not be onerous
## to write a simple helper like:
##   df() { ws_df_dotfile "$@"; }
## .. and then call, instead

ws_df_dotfile() {
  local dot='' filename='' ln='' dir='' src='' dest=''
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
      ws_df__dotfile_dir "$dest_full"
    fi
    ws_df__dotfile_ln "$src/$filename" "$dest_full"
  fi
}

ws_prop_df__dotfile_dest_dir_default() {
  echo "$HOME"
}

ws_df__dotfile_fn_name() {
  local wsn
  wsn="$(ws_lookup WS_NAME)"
  echo "workstation_props_dotfiles_$wsn";
}

# dest dir config useful for testing, not intended for use
: "${ws_prop_df__dotfile_dest_dir:="$(ws_prop_df__dotfile_dest_dir_default)"}"
: "${ws_df__prop_run_failure:=}"
: "${ws_df__prop_run_current_mode:=check}"

ws_df__dotfile_ln(){
  case "$ws_df__prop_run_current_mode" in
    (check) ws_df__dotfile_ln_check "$@";;
    (fix) ws_df__dotfile_ln_fix "$@";;
    (*) echo "ws_df__prop_run_current_mode unexpected value '$ws_df__prop_run_current_mode'" 1>&2; exit 1;;
  esac
}

ws_df__dotfile_ln_check() {
  local src="$1" dest="$2" dest_actual=
  if ! [[ -e "$src" ]]; then
    echo "error: no file found at '$src'" 1>&2;
    ws_df__prop_run_failure=true
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
      ws_df__prop_run_failure=true
      return 9;
    fi
  elif ! [[ -e "$dest" ]]; then
    echo "error: '$dest' does not exist (expected symlink to '$src')" 1>&2
    ws_df__prop_run_failure=true;
    return 8;
  else
    echo "error: expected '$dest' symlink to '$src', but is normal file" 1>&2
    ws_df__prop_run_failure=true;
    return 11;
  fi
}

ws_df__dotfile_ln_fix() {
  local src="$1" dest="$2" dest_actual=

  if ! [[ -e "$src" ]]; then
    echo "error: no file found at '$src'" 1>&2;
    ws_df__prop_run_failure=true
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

ws_df__dotfile_dir() {
  case "$ws_df__prop_run_current_mode" in
    (check) ws_df__dotfile_dir_check "$@";;
    (fix) ws_df__dotfile_dir_fix "$@";;
    (*) echo "ws_df__prop_run_current_mode unexpected value '$ws_df__prop_run_current_mode'" 1>&2; exit 1;;
  esac
}

ws_df__dotfile_dir_check() {
  local dest_full="$1" dest_dir
  dest_dir="$(dirname "$dest_full")"
  if ! [[ -e "$dest_dir" ]]; then
    echo "no directory exists at '$dest_dir'" 1>&2
    ws_df__prop_run_failure=true
    return 8;
  fi
}

ws_df__dotfile_dir_fix() {
  local dest_full="$1" dest_dir
  dest_dir="$(dirname "$dest_full")"
  if ! [[ -e "$dest_dir" ]]; then
    echo "creating directory '$dest_dir'" 1>&2
    mkdir -p "$dest_dir"
  fi
}
