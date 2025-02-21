export WS_CONFIG=$HOME/.config/workstation
export WS_DIR=$HOME/.local/share/ws

workstation_names=(ci_macos ci_ubuntu);
workstation_descriptions_ci_macos="profile for macos on CI"
workstation_descriptions_ci_ubuntu="profile for ubuntu on CI"

[ -f "${WS_CONFIG}/settings.current.sh" ] && . "${WS_CONFIG}/settings.current.sh" || return 0
