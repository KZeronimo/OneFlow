#!/bin/bash

CORRECT_BR=${1:-};
[[ -z $CORRECT_BR ]] && { git pprint -eo "'CORRECT_BR' is required!$"; exit 1; };

WRONG_BR=$(git symbolic-ref --short HEAD);
TARGET_BR=${2-develop};

if [[ -z $(git branch --list "$CORRECT_BR") ]]; then
    # Create correct br - HEAD point to correct br - correct br and wrong br point to the same commit
    # Force wrong br back n commits - HEAD does NOT move
    # Rebase commits between HEAD and wrong br onto target br
    git checkout -b "$CORRECT_BR" && git branch -f "$WRONG_BR" "${3-$WRONG_BR'@{u}'}" && git rebase --onto "$TARGET_BR" "$WRONG_BR" && git pprint -io "Commits migrated to '$CORRECT_BR'!";
else
    # Assume correct br is branched off the correct trunk (has the correct br point)
    # Checkout SHA1 of wrong br - detached HEAD state
    # Force wrong br back n commits - HEAD does NOT move
    # Rebase commits between HEAD and wrong br onto new br
    # Checkout correct br and reset HEAD
    git checkout "$(git rev-parse HEAD)" && git branch -f "$WRONG_BR" "${3-$WRONG_BR'@{u}'}" && git rebase --onto "$CORRECT_BR" "$WRONG_BR" && git checkout -B "$CORRECT_BR" HEAD && git pprint -io "Commits migrated to '$CORRECT_BR'!";
fi;
