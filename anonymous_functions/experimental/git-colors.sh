#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

for i in {0..7}; do echo "$(tput setaf "$i")Color $i$(tput sgr 0)"; done;

