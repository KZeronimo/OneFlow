#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

bpush() {
    while getopts ':drx' flg; do
        case $flg in
        d)
            ;;
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
};

bpush "$@";
