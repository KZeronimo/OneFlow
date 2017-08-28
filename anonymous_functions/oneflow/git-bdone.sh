#!/bin/bash
set -euo pipefail;

bdone() {
    git pprint -if "Updating branch \x27${2-develop}\x27" && git checkout "${2-develop}" && git pull && git bclean "${1-origin}" "${2-develop}" && git pprint -sf "bdone succeeded!";
};

bdone "$@";
