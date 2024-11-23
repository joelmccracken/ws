#!/usr/bin/env bash
: "${TO_WORKSTATION_DIR:=$HOME/workstation}"
: "${WORKSTATION_VERSION:=refs/heads/master}"

TMPDIR=$(mktemp -d "/tmp/ws-install-XXXXXX")

# installer of ws tool/project
cd "$TMPDIR"
curl -L https://github.com/joelmccracken/workstation/archive/${WORKSTATION_VERSION}.tar.gz | tar zx

mkdir -p "$TO_WORKSTATION_DIR"
cd "$TO_WORKSTATION_DIR"
# mv "$TMPDIR" workstation-*/* workstation-*/.* . 2>&1 > /dev/null

for f in ${TMPDIR}/workstation-*/* ${TMPDIR}/workstation-*/.*; do
    mv "$f" . ;
done

# TODO handle fixing dir into repo support
# git init .
# git submodule update
