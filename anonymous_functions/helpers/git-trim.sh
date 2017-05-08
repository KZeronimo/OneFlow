#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

INPUT=${1:-};

[[ -z $INPUT ]] && { git pprint -eo "A string to operate on is required!"; exit 1; };

sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//' <<< "$INPUT";
