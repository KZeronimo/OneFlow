#!/bin/bash
set -euo pipefail;

if [[ ! -z ${1:-} ]]; then printf "%s\n" "$1"; printf "%s\n" "${1// }"; else printf "%s\n" "Empty param"; fi;
