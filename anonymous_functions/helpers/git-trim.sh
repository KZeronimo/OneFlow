#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

trim() {
    local -r string=${1:-};

    [[ -z $string ]] && { git pprint -eo "A string to operate on is required!"; exit 1; };

    sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//' <<< "$string";
};

trim "$@";
