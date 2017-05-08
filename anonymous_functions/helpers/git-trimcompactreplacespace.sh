#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

trimcompactreplacespace() {
    local lwr_flg=0;
    local upr_flg=0;

    # Process command options
    while getopts ':lu' flg; do
        case $flg in
        l)
            lwr_flg=1;;
        u)
            upr_flg=1;;
        *)
            git pprint -eo "Invalid option expecting '[-l|u]'!";
            exit 1;;
        esac
    done;
    shift $((OPTIND - 1));

    local -r string=${1:-};
    local pat=${2:-};

    [[ -z $string ]] && { git pprint -eo "A string to operate on is required!"; exit 1; };
    [[ -z $pat ]] && { git pprint -eo "A relacement string is required!"; exit 1; };

    pat='s/ /'"$pat"'/g';
    git trim "$string" | tr -s ' ' |

    if [[ lwr_flg -eq 1 ]]; then
        tr '[:upper:]' '[:lower:]' | sed -e "$pat";
    elif [[ upr_flg -eq 1 ]]; then
        tr '[:lower:]' '[:upper:]' | sed -e "$pat";
    else
        sed -e "$pat";
    fi;
};

trimcompactreplacespace "$@";
