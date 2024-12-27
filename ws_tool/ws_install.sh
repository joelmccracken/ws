#!/usr/bin/env bash

: "${WORKSTATION_DIR:=$HOME/.config/workstation/workstation_source}"
: "${WORKSTATION_VERSION:=workcomp}"

TMPINST=$(mktemp -d "${TMPDIR:-/tmp}/ws-install.XXXXXXXXX")
# installer of ws tool/project
( cd "$TMPINST";
  curl -L https://github.com/joelmccracken/workstation/archive/${WORKSTATION_VERSION}.tar.gz | tar zx

  mkdir -p "$WORKSTATION_DIR"
  mv "${TMPINST}"/workstation-*/{,.[^.]}* "$WORKSTATION_DIR"
)
