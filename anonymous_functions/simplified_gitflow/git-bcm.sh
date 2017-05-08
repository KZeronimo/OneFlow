#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

TEMP=$(git symbolic-ref --short HEAD);
declare -r THIS_BR=$TEMP;
DID_COMMIT=0;
DIRECT_FLG=0;

# Process command options
while getopts ":d" FLG; do
    case $FLG in
    d)
        DIRECT_FLG=1;;
    *)
        exit 1;;
    esac
done;

[[ $THIS_BR = 'develop' && $DIRECT_FLG -eq 0 ]] && git pprint -eo "Direct commit to 'develop' is not allowed!" && exit 1;
[[ $THIS_BR = 'master' ]] && git pprint -eo "Direct commit to 'master' is not allowed!" && exit 1;

if [[ $(git status --porcelain) ]]; then
    git pprint -gf "Ok - lets get your working directory committed - here is your status and the last 5 commits.\n" | fold -sw 100;

    git status && echo;
    git logbase --all --graph -5 && echo;

    ADD_PARAM=$(git pprint -pd "Add tracked and untracked changes (a) or just tracked changes (t)? Default value is just tracked (t): ");
    grep -E -w -i -q "^a$|^t$" <<< "$ADD_PARAM" && ADD_PARAM=$(git trim "$ADD_PARAM" | tr '[:upper:]' '[:lower:]') || ADD_PARAM="t";

    COMMIT_MSG=$(git pprint -pd "Enter a commit message. Default value is 'SAVEPOINT': ");
    [[ -z $COMMIT_MSG ]] && COMMIT_MSG='SAVEPOINT' || COMMIT_MSG=$(git trim "$COMMIT_MSG");

    if [[ $ADD_PARAM = "a" ]]; then
        git add -A && git commit -m "$COMMIT_MSG" && DID_COMMIT=1;
    else
        git commit -am "$COMMIT_MSG" && DID_COMMIT=1;
    fi;
    [[ $DID_COMMIT -eq 1 ]] && git pprint -io "Changes committed!";
else
    git pprint -wo "Nothing to commit - working directory is clean!";
fi;
