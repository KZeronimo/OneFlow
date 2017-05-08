#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

if [[ $1 -eq 1 ]] || grep -E -i -w -q "true" <<< "$(git config workflow.dorebase)"; then
    git pprint -io "Checking if there are commits for interactive rebase!";
    if [[ $(git rev-list --count "$2".."$3") -gt 0 ]]; then
        git pprint -io "Starting interactive rebase for '$3'!";
        git rebase -i "$(git merge-base "$2" "$3")"
    else
        git pprint -eo "No commits between '$2..$3' for interactive rebase!";
    fi;
fi;
