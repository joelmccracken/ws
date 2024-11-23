#!/usr/bin/env bash

retfunc() {
    # use set -o posix
    # plus saving and restoring sets
    # to make set print vars (and not functions)
    local orig_sets=$(set +o)
    set -o posix
    "$@";

    set | while read i; do
        printf "VAR:%s" "$i";
    done
    # declare -p __ret
    eval "$orig_sets"
}
