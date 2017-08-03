#!/bin/bash
set -euo pipefail;

ispushed() {
    local has_remote_ref='';

    while getopts ':*' _; do
        :;
    done;
    shift $((OPTIND - 1));

    has_remote_ref=$(git ls-remote -h -q --refs "${1-origin}" "$(git symbolic-ref --short HEAD)") && if [[ -n $has_remote_ref && -n $(git rev-parse --symbolic-full-name '@{push}'  2>/dev/null) ]]; then echo 1; else echo 0; fi || exit 1;
};

ispushed "$@";
