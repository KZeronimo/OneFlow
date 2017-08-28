#!/bin/bash
set -euo pipefail;

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
            git pprint -ef "Invalid option expecting \x27[-r|x]\x27!";
            exit 1;;
        esac
    done;

    git bup -p "$@";
};

bpush "$@";
