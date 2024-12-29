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
