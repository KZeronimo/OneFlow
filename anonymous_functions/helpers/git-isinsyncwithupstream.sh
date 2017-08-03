#!/bin/bash
set -euo pipefail;

isinsyncwithupstream() {
    local -r this_br=${1-$(git symbolic-ref --short HEAD)};
    local -r remote=$(git config --local branch."$this_br".remote);
    local -r merge_ref=$(git config --local branch."$this_br".merge);

   [[ -n $remote &&  -n $merge_ref ]] && local -r upstream_commit=$(git ls-remote "$remote" "$merge_ref") || local -r upstream_commit='';

    if [[ -z $upstream_commit ]]; then
        if grep -iq "no upstream" <<< "$(git rev-parse --verify "${this_br}@{u}" 2>&1)"; then echo 'no_upstream'; else echo 'upstream_removed'; fi;
    else
        # shellcheck disable=SC2046
        # we need $(git rev-parse --abbrev-ref @'{u}' | sed 's%/% %g') to word split on the space between 'remote' and 'branch'
        [[ $(git rev-parse "$this_br") = $(git ls-remote $(git rev-parse --abbrev-ref "${this_br}@{u}" | sed 's%/% %g') | cut -f1) ]] && echo 'in_sync' || echo 'out_of_sync';
    fi;
};

isinsyncwithupstream "$@";
