#!/bin/bash
set -euo pipefail;

brbi() {
    if [[ $1 -eq 1 ]] || grep -iq "^true$" <<< "$(git config workflow.dorebase)"; then
        git pprint -if "Checking if there are commits for interactive rebase";
        if [[ $(git rev-list --count develop..develop) -gt 0 ]]; then
            git pprint -if "Starting interactive rebase for \x27$3\x27";
            git rebase -i "$(git merge-base "$2" "$3")";
        else
            git pprint -wf "No commits between \x27$2..$3\x27 for interactive rebase!";
        fi;
    fi;
};

brbi "$@";
