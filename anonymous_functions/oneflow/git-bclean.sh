#!/bin/bash

bclean() {
    # git branch output is formatted with 2 leading characters '* br-name' or '  br-name'
    local -r merged_br=($(git branch --merged "${2-develop}" | grep -Ewv "\* ${2-develop}|  ${2-develop}|\* develop|  develop|\* master|  master"));

    set -eo pipefail;
    [[ ${merged_br[*]} ]] && printf "%s" "${merged_br[*]}" | xargs git branch -d && git pprint -if "Merged branches have been pruned";
    git remote prune "${1-origin}" && git pprint -if "Stale tracking branches have been pruned";
};

bclean "$@";
