#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

THIS_BR=$(git symbolic-ref --short HEAD);
RBI_FLG=0;

while getopts ":r" FLG; do
    case $FLG in
    r)
        RBI_FLG=1;;
    *)
        echo "$(tput setaf 1)Invalid option expecting '[-r]'!$(tput sgr 0)";
        exit 1;;
    esac
done;
shift $((OPTIND - 1));

if [[ $THIS_BR != "${2-develop}" ]]; then
    echo "$(tput setaf 2)Updating branch '$THIS_BR'!$(tput sgr 0)" && git pull "${1-origin}" "${2-develop}";
fi && git brbi ${RBI_FLG} "${2-develop}" "$THIS_BR";
