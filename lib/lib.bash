is_mac() {
  [[ "$(uname)" == 'Darwin' ]]
}

is_linux() {
  [[ "$(uname)" == 'Linux' ]]
}

find_bracketed_content() {
  local line phase=before start_bracket="$1" end_bracket="$2"
  local before="" content="" after=""
  while read -r line; do
    if [[ "$phase" ==  "before" ]]; then
      if [[ "$line" == "$start_bracket" ]]; then
        phase=content;
        content+="$line"$'\n'
      else
        before+="$line"$'\n'
      fi
    elif [[ "$phase" ==  "content" ]]; then
      content+="$line"$'\n'
      if [[ "$line" == "$end_bracket" ]]; then
        phase=end;
      fi
    elif [[ "$phase" == "end" ]]; then
      after+="$line"$'\n'
    fi
  done
  REPLY=("$before" "$content" "$after")
  return 0
}

_mktemp() {
  mktemp -d "${TMPDIR:-/tmp}/${1}.XXXXXXXXX"
}

mv_to_backup() {
  local the_file="$1" new=
  new="${the_file}-$(date +"%s")"
  if [[ -e "$the_file" ]]; then
    mv "$the_file" "$new" > /dev/null
    echo "$new"
  fi
}

safe_overwrite() {
  new="$1"
  orig="$2"

  mv_to_backup "$orig"
  mv "$new" "$orig"
}

load_if_exists() {
  if [ -f "$1" ]; then
    . "$1"
  fi
}

load_expected() {
  if [ -f "$1" ]; then
    . "$1"
  else
    error "ws: init: expected to load file $1, but no file found"
  fi
}

# very dumb way to parse json using bash-only
# why? bc I want to delay requiring jq as long as possible
# this could be done in a better way someday
# found a posix-sh json parser on gh somewhere,
# TODO maybe use that. but looking at the impl for that,
# using bashisms would seemlingly be much better.
dumb_json_parse_string_value() {
  local key="$1" json="$2" tmp tmp2
  after_key="${json#*\""$key"\":}"
  value="${after_key#\"}"
  tmp2="${value%%[\"\}]*}"
  echo "${tmp2%%\"*}"
}

ws_get_ts() {
  date +"%s"
}
