#!/usr/bin/env bash

source "./lib/config_gen.bash"

gen_config_readme_content > "sample_config/README.md"
gen_config_settings_content "default" "primary workstation" > "sample_config/settings.sh"
gen_config_settings_workstation_named "default" > "sample_config/settings.default.sh"
gen_config_config_file_contents "default" > "sample_config/config.sh"
