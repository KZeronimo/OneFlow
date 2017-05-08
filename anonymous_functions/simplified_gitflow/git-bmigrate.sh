#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

declare -r CORRECT_BR=${1:-};
declare -r TARGET_BR=${2:-};
declare -r WRONG_BR=${3-$(git symbolic-ref --short HEAD)};
DID_COMMIT=0;
MAX_COMMITS=0;
MV_PROMPT="";

[[ -z $CORRECT_BR ]] && git pprint -eo "'CORRECT_BR' is required!" && exit 1;
[[ -z $TARGET_BR ]] && git pprint -eo "'TARGET_BR' is required!" && exit 1;
[[ -z $(git branch --list "$TARGET_BR") ]] && git pprint -eo "The branch '$TARGET_BR' must exist!" && exit 1;
[[ -z $(git branch --list "$WRONG_BR") ]] && git pprint -eo "The branch '$WRONG_BR' must exist!" && exit 1;
[[ $CORRECT_BR = "$WRONG_BR" ]] && git pprint -eo "Check the command parameters - 'CORRECT_BR' and 'WRONG_BR' can not be equal!" && exit 1;
[[ $CORRECT_BR = 'master' || $WRONG_BR = 'master' ]] && git pprint -eo "Modification of commits on 'master' is not allowed!" && exit 1;
[[ $CORRECT_BR = 'develop' ]] && git pprint -wf "You are attempting to move commits to 'develop' - You may not be able to push 'develop' directly to the remote!\n" '\n' && ABORT=$(git pprint -pd "Press ENTER to continue or (a) to abort: ") && grep -E -w -i -q "^a$" <<< "$ABORT" && exit 1;
[[ $WRONG_BR != $(git symbolic-ref --short HEAD) ]] && git pprint -wf "Migration requires '$WRONG_BR' to be the current current branch - attempting to checkout '$WRONG_BR'" '\n'  && [[ -z $(git checkout "$WRONG_BR" 2>/dev/null) ]] && git pprint -eo "Checkout of '$WRONG_BR' failed!" && exit 1;

if [[ -n $(git status --porcelain) ]]; then
    git bcm -d && DID_COMMIT=1;
    MV_PROMPT="Commit '$(git rev-parse --short HEAD)' will be moved from '$WRONG_BR' to '$CORRECT_BR' - would you like to move additional commits? Max value is MAX_COMMITS. Default value is 0: ";
else
    MV_PROMPT="How many commits from '$WRONG_BR' to '$CORRECT_BR' would you like to move? Max value is MAX_COMMITS. Default value is 0: ";
fi;

if [[ -n $(git rev-parse --abbrev-ref --symbolic-full-name @'{u}' 2>/dev/null) && $(git rev-list --count @'{u}'..) -gt 0 ]]; then
    MAX_COMMITS=$(git rev-list --count @'{u}'..);
    echo;
    git logbase @'{u}'..;
    echo;
elif [[ $(git rev-list --count "$TARGET_BR"..HEAD) -gt 0 ]]; then
    MAX_COMMITS=$(git rev-list --count "$TARGET_BR"..HEAD);
    echo;
    git logbase --graph "$TARGET_BR"..'HEAD';
    echo;
else
    git pprint -eo "No commits on '$WRONG_BR' can be safely moved!";
    exit 1;
fi;

[[ $DID_COMMIT -eq 1 ]] && MAX_COMMITS=$((MAX_COMMITS - 1));
# Only prompt if there are additional commits to move
[[ $MAX_COMMITS -gt 0 ]] && MV_PROMPT=$(sed 's/MAX_COMMITS/'"$MAX_COMMITS"'/g' <<< "$MV_PROMPT") && NUM_COMMITS=$(git pprint -pd "$MV_PROMPT");
[[ ${NUM_COMMITS} =~ ^[0-9]{1,}$ ]] && { [[ $NUM_COMMITS -gt $MAX_COMMITS ]] && NUM_COMMITS=$MAX_COMMITS || :; } || NUM_COMMITS=0;

[[ $DID_COMMIT -eq 1 ]] && NUM_COMMITS=$((NUM_COMMITS + 1)); git migrate "$CORRECT_BR" "$TARGET_BR" HEAD~$NUM_COMMITS;
