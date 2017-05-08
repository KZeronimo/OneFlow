#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

while getopts ":abc" FLAG; do case $FLAG in *) echo "$FLAG" $OPTIND "${OPTARG:-}";; esac done;
