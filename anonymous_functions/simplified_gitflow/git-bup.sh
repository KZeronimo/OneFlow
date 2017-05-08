#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

TEMP=$(git symbolic-ref --short HEAD);
declare -r THIS_BR=$TEMP;
PUSH_FLG=0;
RBI_FLG=0;
XPR_FLG=0;
DID_BR_POINT_UPD=0;
DID_BR_UPD=0;
DID_BR_RPLY=0;
DID_BR_RBI=0;
DID_PROC_PUSH=0;

while getopts ":pr" FLG; do
    case $FLG in
    p)
        PUSH_FLG=1;;
    r)
        RBI_FLG=1;;
    x)
        XPR_FLG=1;;
    *)
        git pprint -eo "Invalid option expecting '[-r|x]'!";
        exit 1;;
    esac
done;
shift $((OPTIND - 1));

if [[ $XPR_FLG -eq 0 ]]; then
    # Update the given branch point
    git pprint -io "Updating branch '${2-develop}'!";
    git checkout "${2-develop}" && git pull && DID_BR_POINT_UPD=1;
fi && {
    if [[ $THIS_BR != 'develop' && $THIS_BR != 'master' ]]; then
        if [[ $XPR_FLG -eq 0 ]]; then
            HAS_UPSTREAM=$(git ls-remote -h -q --refs "${1-origin}" "$THIS_BR");
            git checkout "$THIS_BR" && {

                # If we have an upstream then sync up
                if [[ -n $HAS_UPSTREAM ]]; then
                    git pprint -io "Updating branch '$THIS_BR'!";
                    git pull && DID_BR_UPD=1;
                # If local branch upstream has been yanked then clean up
                elif [[ -n $(git rev-parse --symbolic-full-name '@{upstream}' 2>/dev/null) ]]; then
                    git pprint -wo "Unsetting upstream for '$THIS_BR'!";
                    git branch --unset-upstream;
                fi; } && {

                    # If this is a feature branch then rebase onto given branch point
                    if grep -q "^feature" <<< "$THIS_BR" && [[ $(git show-ref --heads -s "${2-develop}") != $(git merge-base "${2-develop}" "$THIS_BR") ]]; then
                        git pprint -io "Replaying '$THIS_BR' onto '${2-develop}'!";
                        git rebase -p "${2-develop}" && DID_BR_RPLY=1;
                    fi; } && git brbi ${RBI_FLG} "${2-develop}" "$THIS_BR" && DID_BR_RBI=1 && git pprint -so "bup|fresh succeeded!";
        elif [[ $RBI_FLG -eq 1 ]]; then
             git pprint -wo "Interactive rebase request will not be honored in eXpress push mode!";
        fi && {
            # Process push
            IS_PUSHED=$(git ispushed "$@");

            # Should push
            if [[ $PUSH_FLG -eq 0 && $IS_PUSHED -eq 1 && ($DID_BR_RPLY || $DID_BR_RBI) ]]; then
                git pprint -wo "'$THIS_BR' has been previously pushed - syncing with '${1-origin}'!";
                git push --force-with-lease && DID_PROC_PUSH=1;
            elif [[ $PUSH_FLG -eq 1 ]]; then
                if [[ $(git isinsyncwithrmt) -eq 0  ]]; then
                    git pprint -io "Pushing '$THIS_BR' to '${1-origin}'!";
                    # Pushed prior
                    if [[ $IS_PUSHED -eq 1 ]]; then
                        git push --force-with-lease && DID_PROC_PUSH=1;
                    # First push
                    else
                        git push -u "${1-origin}" "$THIS_BR" && DID_PROC_PUSH=1;
                    fi;
                else
                    git pprint -wo "Nothing to push - '$THIS_BR' is in sync with '${1-origin}'!";
                    DID_PROC_PUSH=1;
                fi;
            fi && [[ DID_PROC_PUSH -eq 1 ]] && git pprint -so "bpush|saved succeeded!" || :; };
    else
        git pprint -wo "Directly pushing to '$THIS_BR' is not allowed!";
        [[ $RBI_FLG -eq 1 ]] && git pprint -wo "Rebase is not allowed for '$THIS_BR'!";
        [[ $DID_BR_POINT_UPD -eq 1 ]] && git pprint -so "bup|fresh succeeded!";
    fi; };
