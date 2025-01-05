export WS_CONF=$HOME/.config/workstation
export WS_DIR=$WS_CONF/vendor/ws

workstation_names=(ci_macos ci_ubuntu);
workstation_descriptions_ci_macos="profile for macos on CI"
workstation_descriptions_ci_ubuntu="profile for ubuntu on CI"

[ -f "${WS_CONF}/settings.current.sh" ] && . "${WS_CONF}/settings.current.sh" || return 0
