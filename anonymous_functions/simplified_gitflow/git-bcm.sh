#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

bcm() {
    local -r this_br=$(git symbolic-ref --short HEAD);
    local add_param='';
    local commit_msg='';
    local did_commit=0;
    local direct_flg=0;

    # Process command options
    while getopts ':d' flg; do
        case $flg in
        d)
            direct_flg=1;;
        *)
            exit 1;;
        esac
    done;
    shift $((OPTIND - 1));

    [[ $this_br = 'develop' && $direct_flg -eq 0 ]] && git pprint -eo "Direct commit to 'develop' is not allowed!" && exit 1;
    [[ $this_br = 'master' ]] && git pprint -eo "Direct commit to 'master' is not allowed!" && exit 1;

    if [[ $(git status --porcelain) ]]; then
        git pprint -gf "Ok - lets get your working directory committed - here is your status and the last 5 commits.\n" | fold -sw 100;

        git status && echo;
        git logbase --all --graph -5 && echo;

        add_param=$(git pprint -pd "Add tracked and untracked changes (a) or just tracked changes (t)? Default value is just tracked (t): ");
        grep -Eiq "^a$|^t$" <<< "$add_param" && add_param=$(git trim "$add_param" | tr '[:upper:]' '[:lower:]') || add_param="t";

        commit_msg=$(git pprint -pd "Enter a commit message. Default value is 'SAVEPOINT': ");
        [[ -z $commit_msg ]] && commit_msg='SAVEPOINT' || commit_msg=$(git trim "$commit_msg");

        if [[ $add_param = "a" ]]; then
            git add -A && git commit -m "$commit_msg" && did_commit=1;
        else
            git commit -am "$commit_msg" && did_commit=1;
        fi;
        [[ $did_commit -eq 1 ]] && git pprint -io "Changes committed";
    else
        git pprint -wo "Nothing to commit - working directory is clean!";
    fi;
};

bcm "$@";
