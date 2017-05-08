#!/bin/bash
set -euo pipefail;
IFS=$' \n\t';

while getopts ":*" _; do
    :;
done;
shift $((OPTIND - 1));

# shellcheck disable=SC2046
# currently we need $(git rev-parse --abbrev-ref '@{push}' | sed 's%/% %g') to word split on the space between 'remote' and 'branch'
[[ -n $(git rev-parse --symbolic-full-name '@{push}' 2>/dev/null) && $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref '@{push}' | sed 's%/% %g') | cut -f1) ]] && echo 1 || echo 0;
