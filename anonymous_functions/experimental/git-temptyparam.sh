#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

if [[ ! -z "${1:-}" ]]; then echo "$1"; echo "${1// }"; else echo "Empty param"; fi;
