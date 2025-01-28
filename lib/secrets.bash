#!/usr/bin/env bash

# feature requires the following external dependencies
# - bitwarden-cli
# - jq
# it is suggested to ensure this property comes after
# another that ensures those are installed
#
# manage secrets on local workstation
# use bitwarden secure notes as storage mechanism
#
# to start:
# - set your bitwarden username and password as
#   export WS_BW_EMAIL='...'
#   export WS_BW_MASTER_PASS='...'
# - execute bitwarden-secrets init
#   stores bw email and master pass in ~/secrets
#   for future uses, with appropriate permissions.

set -euo pipefail

export BW_SESSION

ws_secrets__bw() {
  # silence goofungered warning
  NODE_OPTIONS="--no-deprecation" bw "$@"
}

ws_secrets__needs_init() {
  [[ ! (-f "$HOME/secrets/bw_master_pass"  && \
        -f "$HOME/secrets/bw_email" ) ]]
}

ws_secrets__init() {
  # why is bash so cryptic
  if [[ -n "${WS_BW_EMAIL+x}" && \
        -n "${WS_BW_MASTER_PASS+x}" ]]; then
      echo variables requried to initialize are set
      if [ ! -d ~/secrets ]; then
          mkdir ~/secrets;
      fi
      echo -n "${WS_BW_MASTER_PASS}" > ~/secrets/bw_master_pass
      chmod 0600 "$HOME/secrets/bw_master_pass"
      echo -n "${WS_BW_EMAIL}" > ~/secrets/bw_email
      chmod 0600 "$HOME/secrets/bw_email"
      BW_SESSION="$(ws_secrets__bw login "$(cat ~/secrets/bw_email)" \
                     --passwordfile ~/secrets/bw_master_pass --raw)"
      ws_secrets__bw_unlock
      ws_secrets__bw sync
      return 0
  else
    info variables required to run bww force sync are MISSING, cannot init
    return 10
  fi
}

ws_secrets__bw_unlock() {
  BW_SESSION="$(ws_secrets__bw unlock --passwordfile ~/secrets/bw_master_pass --raw)"
}

ws_secrets__find_folder_by_name_returning_id () {
  local name="$1" id
  ws_secrets__bw list folders --search "$name" | \
    jq --raw-output ". | map(select(.name == \"$name\")) | first | .id | tostring"
}

ws_secrets__create_folder_by_name_returning_id() {
  local name="$1" id
  ws_secrets__bw get template folder | jq ".name=\"$name\"" | ws_secrets__bw encode | ws_secrets__bw create folder | jq --raw-output '.id'
}

ws_secrets__find_or_create_folder_by_name_returning_id() {
  local id name="$1"
  id="$(ws_secrets__find_folder_by_name_returning_id "$name")"
  if [[ $id == "null" ]]; then
    ws_secrets__create_folder_by_name_returning_id "$name"
  else
    echo "$id"
  fi
}

ws_secrets__sync_files() {
  ws_secrets__bw_unlock
  ws_secrets__bw sync

  bw_files_folder="$(ws_secrets__find_or_create_folder_by_name_returning_id "bww_files")"
  items="$(ws_secrets__bw list items --folderid "$bw_files_folder" | jq --compact-output '.[] | {id, name, notes }')"
  echo "$items" | while read -r item; do
    notes="$(echo "$item" | jq --raw-output '.notes')"
    name="$(echo "$item" | jq --raw-output '.name')"
    id="$(echo "$item" | jq --raw-output '.id')"

    fname="${name#file:}"
    absname="${fname/#~/$HOME}"

    if [[ -e "$absname" ]]; then
      current="$(cat "$absname")"
      if ! diff <(echo -n "$current") <(echo -n "$notes"); then
        local oldext
        oldext="$(date -Iseconds -u)"
        mv "$absname" "$absname.backup-$oldext"
        echo -n "$notes" > "$absname"
      fi
    else
      mkdir -p "$(dirname "$absname")"
      echo -n "$notes" > "$absname"
    fi
    chmod 0600 "$absname"
  done
  ws_secrets__save_last_sync_at_ts
}

ws_secrets__add_file() {
  local new_file="$1"
  new_file="$(realpath "$new_file")"
  bw_files_folder="$(ws_secrets__find_or_create_folder_by_name_returning_id "bww_files")"
  ws_secrets__bw get template item \
    | jq --arg folderId "$bw_files_folder" \
         --arg fname "file:${new_file/#$HOME/~}" \
         --arg filecontent "$(cat < "$new_file")" \
        ". | (.type = 2 | \
              .name=\$fname | \
              .folderId=\$folderId | \
              .notes=\$filecontent | .secureNote={type: 0})" \
    | ws_secrets__bw encode | ws_secrets__bw create item > /dev/null
}

ws_secrets__save_last_sync_at_ts() {
  mkdir -p "$HOME/.local/state/bitwarden-secrets"
  ws_get_ts > "$HOME/.local/state/bitwarden-secrets/last-sync-ts"
}

ws_secrets__get_last_sync_ts() {
  if [[ -f "$HOME/.local/state/bitwarden-secrets/last-sync-ts" ]]; then
    cat "$HOME/.local/state/bitwarden-secrets/last-sync-ts"
  else
    echo "0"
  fi
}

ws_secrets__time_to_resync() {
  local last_sync now

  last_sync="$(ws_secrets__get_last_sync_ts)"
  now="$(ws_get_ts)"

  if (( (last_sync + (60*60*24*7)) < now )); then
    return 0;
  else
    return 1;
  fi
}

bitwarden_secrets_main () {
  arg="$1";
  shift;
  case "$arg" in
    (init) ws_secrets__init;;
    (check-needs-sync) ws_secrets__time_to_resync "$@";;
    (sync) ws_secrets__sync_files;;
    (add) ws_secrets__add_file "$2";;
    (*) echo "unrecognized: $1";;
  esac
}
