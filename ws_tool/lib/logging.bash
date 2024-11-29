log_level_num() {
  msg_lvl="$1"
  case "$msg_lvl" in
    emerg)  lvl_num=1;;
    alert)  lvl_num=2;;
    crit)   lvl_num=3;;
    error)  lvl_num=4;;
    warn)   lvl_num=5;;
    notice) lvl_num=6;;
    info)   lvl_num=7;;
    debug)  lvl_num=8;;
    *) lvl_num=8;; # default at debug, something is wrong
  esac;
  __ret="$lvl_num";
}

log() {
  this_lvl="$1"
  shift;
  log_level_num "$WORKSTATION_LOG_LEVEL"
  global_lvl_num="$__ret";

  log_level_num "$this_lvl"
  this_lvl_num="$__ret";
  if (( this_lvl_num <= global_lvl_num )); then
    echo "$this_lvl $(date): $@" 1>&2
  fi
}

function error() {
  log error "$@"
}

function debug() {
  log debug "$@"
}

function info() {
    log info "$@"
}
