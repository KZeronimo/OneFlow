#!/bin/bash
set -euo pipefail;

for i in {0..7}; do echo "$(tput setaf "$i")Color $i$(tput sgr 0)"; done;
