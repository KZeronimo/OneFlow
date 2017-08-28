#!/bin/bash
set -euo pipefail;

while getopts ':abc' flg; do case $flg in *) printf "%s\n" "$flg $OPTIND ${OPTARG:-}";; esac done;
