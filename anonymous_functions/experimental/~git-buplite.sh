#!/bin/bash
set -euo pipefail;

buplite() {
    local -r this_br=$(git symbolic-ref --short HEAD);
    local rbi_flg=0;

    while getopts ':r' flg; do
        case $flg in
        r)
            rbi_flg=1;;
        *)
            printf "%b\n" "$(tput setaf 1)Invalid option expecting \x27[-r]\x27!$(tput sgr 0)";
            exit 1;;
        esac
    done;
    shift $((OPTIND - 1));

    if [[ $this_br != "${2-develop}" ]]; then
        printf "%b\n" "$(tput setaf 2)Updating branch \x27$this_br\x27!$(tput sgr 0)" && git pull "${1-origin}" "${2-develop}";
    fi && git brbi ${rbi_flg} "${2-develop}" "$this_br";
};

buplite "$@";
