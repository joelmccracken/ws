#!/usr/bin/env bash

# code to generate configs
# ========================
#
# this project started out with hand crafted configs. This stared out fine
# but it quickly became an issue:
# - I'd make a change in one config, but forget in another
# then, it hit me: the configs aren't that much, so I could autogenerate
# them.

gen_config() {
    local dir="$1"
}

gen_config_readme_content() {
  echo "# Workstation Sample Configuration"
}

gen_config_settings_content() {
    local all_workstation_names= all_workstation_descs=()
    eval "all_workstation_names=($1)"
    shift;
    while (( $# > 0)); do
        all_workstation_descs+=("$1");
        shift;
    done

    all_descs=""
    local i=0
    while (( i < ${#all_workstation_names[@]} )); do
        local name="${all_workstation_names[i]}"
        local desc="${all_workstation_descs[i]}"
        all_descs+="workstation_descriptions_$name='$desc';"$'\n'
        (( i++ ))
    done

cat <<-EOF
	# the settings.sh file is used to define basic, general settings for the ws
	# tool.

	# location of config dir
	# where your personal configuration should be
	# (e.g. where this file and your config.sh should be)
	# The ws tool needs to know some things to do its job, such as
	# own source files should be found, what the user wants with their
	# workstation(s), etc.
	# . Having a central file like this affords a central place to
	# configure
	# these things.
	# Wou may wish to customize this if you want your configuration somewhere else.
	# The default location is "\$HOME/.config/workstation".
	# export WS_CONFIG=

	# location of workstation source. This is where the ws tool source code should live.
	# the default location is "\$WS_CONFIG/vendor/ws"
	# (so, "\$HOME/.config/workstation/vendor/ws")
	# export WS_DIR=

	# Workstation name to use.
	# Used to identify a machine, determine which settings it should have.
	# if you just have one, you can use this here and set it to 'default'
	# However, the recommendation is not to set this here, but via
	# settings.current.bash file. See below.
	# export WS_NAME=default

	# workstation_names is an array of names, though it is used
	# names are used to infer the presence of other variables, so each one must
	# be valid for use as part of a variable. i.e., with:
	#   workstation_names=(some_workstation);
	# the ws tool will look for a variable "workstation_description_some_workstation"
	# (defined immediately below) to provide a sort text description of that machine.
	workstation_names=($all_workstation_names);

	# workstation descriptions
	# text descriptionms for different workstations.
	# workstation_descriptions_default="primary workstation"
	$all_descs

	# settings.current.sh
	# One problem that may not be immediately apparent to someone first thinking
	# about this is the issue of having multiple sets of desired configurations
	# for different machines, i.e. I want my work computer to be different from
	# my personal computer and my cloud VM, but, there are also many things I
	# want to be common across them.
	# Even if you are just using this for a single workstation, it is good to
	# have this capability in place and thought about before it is immediately needed.
	# the following is the way I like to support this, and ws is designed for:
	# - Have global/common settings in \$WS_CONFIG/settings.sh
	# - Have workstation-specific settings in \${WS_CONFIG}/settings.\${WS_NAME}.sh
	# - Have a symlink from "\$WS_CONFIG/settings.current.sh" to the specific file
	# - Have a symlink from "\$WS_CONFIG/settings.current.sh" to specific settings
	#   file. Tools can then look in that well-understood spot for any
	#   settings they need.
	# In the past, I've followed this pattern in an expanded way like so:
	# - a 'hosts' subdirectory within my main configuration
	# - a 'hosts/<ws_name>' for each individial workstation,
	# - files in this directory that are specific to each host.
	#   - \$WS_CONFIG/hosts/<ws_name>/settings.sh: shell settings
	#   - \$WS_CONFIG/hosts/<ws_name>/settings.el: emacs lisp settings
	# - a symlink from 'hosts/current' to the relevant 'hosts/<ws_name>' dir.
	# This worked well for me, and it may work for you; a setup like this should
	# be easy to adapt.
	[ -f "\${WS_CONFIG}/settings.current.sh" ] && . "\${WS_CONFIG}/settings.current.sh" || return 0

	# Oh, you may wish to add the following to your shell profile file:
	# export WS_CONFIG=/path/to/specific/location
	# export PATH="\${WS_DIR}:\$PATH"
EOF
}

gen_config_settings_workstation_named() {
  local workstation_name="$1"
  echo "export WS_NAME='$workstation_name'"
}

gen_config_config_file_contents() {
  local workstation_name="$1"
  cat <<-EOF
	workstation_props_$workstation_name=()
	# workstation_props_$workstation_name+=(ws_prop_current_settings_symlink)
EOF
}
