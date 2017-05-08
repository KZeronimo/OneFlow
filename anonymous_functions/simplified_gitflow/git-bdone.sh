#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

git pprint -io "Updating branch '${2-develop}'!" && git checkout "${2-develop}" && git pull "${1-origin}" "${2-develop}" && git bclean "${1-origin}" "${2-develop}" && git pprint -so "bdone succeeded!";
