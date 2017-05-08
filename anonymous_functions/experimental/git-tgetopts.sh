#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

while getopts ':abc' flg; do case $flg in *) echo "$flg" $OPTIND "${OPTARG:-}";; esac done;
