#!/usr/bin/env bash

set -euo pipefail
: "${WS_DIR:=$HOME/.config/workstation/vendor/ws}"
: "${WS_VERSION:=master}"

TMPINST=$(mktemp -d "${TMPDIR:-/tmp}/ws-install.XXXXXXXXX")
# installer of ws tool/project
( cd "$TMPINST";
  curl -L https://github.com/joelmccracken/ws/archive/${WS_VERSION}.tar.gz | tar zx

  if [[ -e "$WS_DIR" ]]; then
    mv "$WS_DIR" "${WS_DIR}-$(date +"%s")"
  fi

  mkdir -p "$WS_DIR"
  mv "${TMPINST}"/ws-*/{,.[^.]}* "$WS_DIR"
)
