#!/bin/bash
set -euo pipefail;

migrate() {
    local -r correct_br=${1:-};
    local -r wrong_br=$(git symbolic-ref --short HEAD);
    local -r target_br=${2-develop};

    [[ -z $correct_br ]] && { git pprint -ef "\x27correct_br\x27 is required!$"; exit 1; };

    if [[ -z $(git branch --list "$correct_br") ]]; then
        # Create correct br - HEAD point to correct br - correct br and wrong br point to the same commit
        # Force wrong br back n commits - HEAD does NOT move
        # Rebase commits between HEAD and wrong br onto target br
        git checkout -b "$correct_br" && git branch -f "$wrong_br" "${3-"${wrong_br}@{u}"}" && git rebase --onto "$target_br" "$wrong_br" && git pprint -if "Commits migrated to \x27$correct_br\x27";
    else
        # Assume correct br is branched off the correct trunk (has the correct br point)
        # Checkout SHA1 of wrong br - detached HEAD state
        # Force wrong br back n commits - HEAD does NOT move
        # Rebase commits between HEAD and wrong br onto new br
        # Checkout correct br and reset HEAD
        git checkout "$(git rev-parse HEAD)" && git branch -f "$wrong_br" "${3-"${wrong_br}@{u}"}" && git rebase --onto "$correct_br" "$wrong_br" && git checkout -B "$correct_br" HEAD && git pprint -if "Commits migrated to \x27$correct_br\x27";
    fi;
};

migrate "$@";
