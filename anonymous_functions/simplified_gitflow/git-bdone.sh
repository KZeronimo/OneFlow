#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

bdone() {
    git pprint -io "Updating branch '${2-develop}'" && git checkout "${2-develop}" && git pull && git bclean "${1-origin}" "${2-develop}" && git pprint -so "bdone succeeded!";
};

bdone "$@";
