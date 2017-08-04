#!/bin/bash
set -euo pipefail;

bmigrate() {
    local -r correct_br=${1:-};
    local -r target_br=${2:-};
    local -r wrong_br=${3-$(git symbolic-ref --short HEAD)};
    local did_commit=0;
    local max_commits=0;
    local num_commits=0;
    local mv_prompt='';

    [[ -z $correct_br ]] && git pprint -ef "\x27correct_br\x27 is required!" && exit 1;
    [[ -z $target_br ]] && git pprint -ef "\x27target_br\x27 is required!" && exit 1;
    [[ -z $(git branch --list "$target_br") ]] && git pprint -ef "The branch \x27$target_br\x27 must exist!" && exit 1;
    [[ -z $(git branch --list "$wrong_br") ]] && git pprint -ef "The branch \x27$wrong_br\x27 must exist!" && exit 1;
    [[ $correct_br = "$wrong_br" ]] && git pprint -ef "Check the command parameters - \x27correct_br\x27 and \x27wrong_br\x27 can not be equal!" && exit 1;
    [[ $correct_br = 'master' || $wrong_br = 'master' ]] && git pprint -ef "Modification of commits on \x27master\x27 is not allowed!" && exit 1;
    [[ $correct_br = 'develop' ]] && git pprint -wf "You are attempting to move commits to \x27develop\x27 - You may not be able to push \x27develop\x27 directly to the remote!\n" '\n' && ABORT=$(git pprint -pd "Press ENTER to continue or (a) to abort: ") && grep -iq "^a$" <<< "$ABORT" && exit 1;
    [[ $wrong_br != $(git symbolic-ref --short HEAD) ]] && git pprint -wf "Migration requires \x27$wrong_br\x27 to be the current branch - attempting to checkout '$wrong_br'!" '\n'  && [[ -z $(git checkout "$wrong_br" 2>/dev/null) ]] && git pprint -ef "Checkout of '$wrong_br' failed!" && exit 1;

    if [[ -n $(git status --porcelain) ]]; then
        git bcm -d && did_commit=1;
        mv_prompt="Commit \x27$(git rev-parse --short HEAD)\x27 will be moved from \x27$wrong_br\x27 to \x27$correct_br\x27 - would you like to move additional commits? Max value is max_commits. Default value is 0: ";
    else
        mv_prompt="How many commits from \x27$wrong_br\x27 to \x27$correct_br\x27 would you like to move? Max value is max_commits. Default value is 0: ";
    fi;

    if [[ -n $(git rev-parse --verify --quiet '@{u}' 2>/dev/null) && $(git rev-list --count @'{u}'..) -gt 0 ]]; then
        max_commits=$(git rev-list --count @'{u}'..);
        echo;
        git logbase @'{u}'..;
        echo;
    elif [[ $(git rev-list --count "$target_br"..HEAD) -gt 0 ]]; then
        max_commits=$(git rev-list --count "$target_br"..HEAD);
        echo;
        git logbase --graph "$target_br"..'HEAD';
        echo;
    else
        git pprint -ef "No commits on '$wrong_br' can be safely moved!";
        exit 1;
    fi;

    [[ $did_commit -eq 1 ]] && max_commits=$((max_commits - 1));
    # Only prompt if there are additional commits to move
    [[ $max_commits -gt 0 ]] && mv_prompt=$(sed "s/max_commits/$max_commits/g" <<< "$mv_prompt") && num_commits=$(git pprint -pd "$mv_prompt");
    [[ ${num_commits} =~ ^[0-9]{1,}$ ]] && { [[ $num_commits -gt $max_commits ]] && num_commits=$max_commits || :; } || num_commits=0;

    [[ $did_commit -eq 1 ]] && num_commits=$((num_commits + 1)); git migrate "$correct_br" "$target_br" "HEAD~$num_commits";
};

bmigrate "$@";
