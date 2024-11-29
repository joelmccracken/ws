#!/usr/bin/env bash

ws_get_all_settings() {
   all_settings=()
   while read line; do
        if [[ "$line" == export*'META:workstation_setting'* ]]; then
            without_export="${line/#export /}"
            var_name="${without_export/%# META:workstation_setting/}"
            all_settings+=("$var_name")
        fi
   done < "$PROJECT_ROOT/lib/settings.bash"
   __r=(${all_settings[@]})
}

ws_unset_settings() {
    ws_get_all_settings
    all_settings=("${__r[@]}")
    unset "${all_settings[@]}"
}

ws_reset_settings () {
    ws_unset_settings
    . "$PROJECT_ROOT/lib/settings.bash"
}
