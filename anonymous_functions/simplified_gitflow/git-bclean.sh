#!/bin/bash
IFS=$'\n\t';

STALE_BR=$(git branch --merged "${2-develop}" | grep -E -v "${2-develop}|develop|master$");

set -euo pipefail;
if [[ -n $STALE_BR ]]; then
     $STALE_BR | xargs git branch -d && git remote prune "${1-origin}" && git pprint -io "Stale branches have been pruned!";
else
    :;
fi;
