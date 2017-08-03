#!/bin/bash
set -euo pipefail;

trim() {
    local -r string=${1:-};

    [[ -z $string ]] && { git pprint -ef "A string to operate on is required!"; exit 1; };

    sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//' <<< "$string";
};

trim "$@";
