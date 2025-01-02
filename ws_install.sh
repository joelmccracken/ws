#!/usr/bin/env bash

set -euo pipefail
: "${WORKSTATION_DIR:=$HOME/.config/workstation/vendor/ws}"
: "${WORKSTATION_VERSION:=master}"

TMPINST=$(mktemp -d "${TMPDIR:-/tmp}/ws-install.XXXXXXXXX")
# installer of ws tool/project
( cd "$TMPINST";
  curl -L https://github.com/joelmccracken/ws/archive/${WORKSTATION_VERSION}.tar.gz | tar zx

  if [[ -e "$WORKSTATION_DIR" ]]; then
    mv "$WORKSTATION_DIR" "${WORKSTATION_DIR}-$(date +"%s")"
  fi

  mkdir -p "$WORKSTATION_DIR"
  mv "${TMPINST}"/ws-*/{,.[^.]}* "$WORKSTATION_DIR"
)
