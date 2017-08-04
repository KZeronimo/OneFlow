#!/bin/bash
IFS=$'\n\t';

bclean() {
    local -r merged_br=($(git branch --merged "${2-develop}" | grep -Ev "^${2-develop}|develop|master$"));

    set -eo pipefail;
    [[ ${merged_br[*]} ]] && echo "${merged_br[*]}" | xargs git branch -d && git pprint -io "Merged branches have been pruned";
    git remote prune "${1-origin}" && git pprint -io "Stale tracking branches have been pruned";
};

bclean "$@";
