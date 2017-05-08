#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

while getopts ":*" _; do
    :;
done;
shift $((OPTIND - 1));

vcmdrslt=$(git ls-remote -h -q --refs "${1-origin}" "$(git symbolic-ref --short HEAD)") && if [[ -n $vcmdrslt && -n $(git rev-parse --symbolic-full-name '@{push}') ]]; then echo 1; else echo 0; fi || exit 1;
