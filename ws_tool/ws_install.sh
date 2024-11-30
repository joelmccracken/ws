#!/usr/bin/env bash

: "${WORKSTATION_DIR:=$HOME/.config/workstation/src}"
: "${WORKSTATION_VERSION:=master}"

TMPDIR=$(mktemp -d "/tmp/ws-install-XXXXXX")

# installer of ws tool/project
cd "$TMPDIR"
curl -L https://github.com/joelmccracken/workstation/archive/${WORKSTATION_VERSION}.tar.gz | tar zx

mkdir -p "$WORKSTATION_DIR"
mv "${TMPDIR}"/workstation-*/{,.[^.]}* "$WORKSTATION_DIR"
