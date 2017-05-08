#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

echo "${1-1}" "${2-2}";
