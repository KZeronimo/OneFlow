#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

while getopts ":r" FLG; do
    case $FLG in
    r)
        ;;
    x)
        ;;
    *)
        git pprint -eo "Invalid option expecting '[-r|x]'!";
        exit 1;;
    esac
done;

git bup -p "$@";
