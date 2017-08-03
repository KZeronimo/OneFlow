#!/bin/bash
set -euo pipefail;

while getopts ':abc' flg; do case $flg in *) echo "$flg" $OPTIND "${OPTARG:-}";; esac done;
