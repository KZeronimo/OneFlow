#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

buplite() {
    local -r this_br=$(git symbolic-ref --short HEAD);
    local rbi_flg=0;

    while getopts ':r' flg; do
        case $flg in
        r)
            rbi_flg=1;;
        *)
            echo "$(tput setaf 1)Invalid option expecting '[-r]'!$(tput sgr 0)";
            exit 1;;
        esac
    done;
    shift $((OPTIND - 1));

    if [[ $this_br != "${2-develop}" ]]; then
        echo "$(tput setaf 2)Updating branch '$this_br'!$(tput sgr 0)" && git pull "${1-origin}" "${2-develop}";
    fi && git brbi ${rbi_flg} "${2-develop}" "$this_br";
};

buplite "$@";
