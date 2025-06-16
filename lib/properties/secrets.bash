#!/usr/bin/env bash

ws_prop_bitwarden_secrets() {
  local ws
  if ws_secrets__needs_init || ws_secrets__time_to_resync; then
    echo "time to sync bitwarden secrets"
    return 1
  else
    echo "recent bitwarden secret sync"
    return 0
  fi
}

ws_prop_bitwarden_secrets_fix() {
  if ws_secrets__needs_init; then
    ws_secrets__init
  fi
  if ws_secrets__time_to_resync; then
    ws_secrets__sync_files
  fi
}
