#!/bin/bash

bclean() {
    local -r merged_br=($(git branch --merged "${2-develop}" | grep -Ev "^${2-develop}|develop|master$"));

    set -eo pipefail;
    [[ ${merged_br[*]} ]] && printf "%s" "${merged_br[*]}" | xargs git branch -d && git pprint -if "Merged branches have been pruned";
    git remote prune "${1-origin}" && git pprint -if "Stale tracking branches have been pruned";
};

bclean "$@";
