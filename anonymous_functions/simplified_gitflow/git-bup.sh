#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

bup() {
    local -r this_br=$(git symbolic-ref --short HEAD);
    local br_sync_status='';
    local br_remote='';
    local did_br_point_upd=0;
    local did_br_upd=0;
    local did_br_rply=0;
    local did_br_rbi=0;
    local did_proc_push=0;
    local direct_flg=0;
    local push_flg=0;
    local rbi_flg=0;
    local xpr_flg=0;

    sync_with_upstream() {
        local -r br=$1;
        local -r sync_status=$(git isinsyncwithupstream);

        # If we have a remote commit and we are out of sync then sync up
        if [[ $sync_status = 'out_of_sync' ]]; then
            git pprint -io "Updating branch '$br'";
            git pull;
        elif [[ $sync_status = 'in_sync' ]]; then
            git pprint -io "Branch '$br' is up-to-date";
        fi;

        # If local branch upstream has been yanked then clean up
        if [[ $sync_status = 'upstream_removed' ]]; then
            git pprint -wo "Unsetting upstream for '$br'!";
            git branch --unset-upstream;
        elif [[ $sync_status = 'no_upstream' ]]; then
            git pprint -io "No upstream set for branch '$br'";
        fi;

        return $?;
    };

    push_to_other_remotes() {
        # Explicity push to remotes that aren't the upstream
        br_remote=$(git config branch."$(git symbolic-ref --short HEAD)".remote);
        if [[ -n $br_remote ]]; then
            # Any other remotes configured besides upstream - then push
            for remote in $(git remote show | grep -v "$br_remote"); do
                git pprint -io "Pushing branch '$this_br' to additional remote '$remote'";
                git push --force-with-lease  "$remote" "$this_br";
            done;
        fi;

        return $?;
    };

    while getopts ':dprx' flg; do
        case $flg in
        d)
            direct_flg=1;;
        p)
            push_flg=1;;
        r)
            rbi_flg=1;;
        x)
            xpr_flg=1;;
        *)
            git pprint -eo "Invalid option expecting '[-r|x]'!";
            exit 1;;
        esac
    done;
    shift $((OPTIND - 1));

    # Validate remote
    if ! grep -q "^${1-origin}$" <<< "$(git remote show)"; then git pprint -eo "Given remote '${1-origin}' is not valid!"; exit 1; fi;

    # No direct manipulation of master allowed
    local -r br_point=${2-develop};
    [[ $this_br = 'master' || $br_point = 'master' ]] && git pprint -eo "Modification of commits on 'master' is not allowed!" && exit 1;

    # Direct flag only has meaning as 'direct push to develop'
    [[ $push_flg -eq 0 && $direct_flg -eq 1 ]] && direct_flg=0;

    # We are on develop or some other branch of interest (feature, release, hot fix)
    sync_with_upstream "$this_br" && did_br_upd=1 && {
        # We are on a branch of interest and the express flag is off
        if [[ $this_br != 'develop' && $xpr_flg -eq 0 ]]; then
            git checkout "$br_point" && sync_with_upstream "$br_point" && did_br_point_upd=1 && git checkout "$this_br" && {
            # If this is a feature branch then rebase onto given branch point
            if grep -q "^feature" <<< "$this_br" && [[ $(git show-ref --heads -s "$br_point") != $(git merge-base "$br_point" "$this_br") ]]; then
                git pprint -io "Replaying '$this_br' onto '$br_point'";
                git rebase -p "$br_point" && did_br_rply=1;
            fi; } && git brbi ${rbi_flg} "$br_point" "$this_br" && did_br_rbi=1;
        elif [[ $rbi_flg -eq 1 && $this_br = 'develop' ]]; then
            git pprint -wo "Rebase is not allowed for 'develop'!";
        elif [[ $rbi_flg -eq 1 && $xpr_flg -eq 1 ]]; then
            git pprint -wo "Interactive rebase request will not be honored in eXpress push mode!";
        fi;
    } && git pprint -so "bup|fresh succeeded!" && {
        # Process push
        # Maintainers have a carve out to directly push to develop (direct_flg is not published)
        [[ $this_br = 'develop' && $push_flg -eq 1 && $direct_flg -eq 0 ]] && git pprint -wo "Directly pushing to '$this_br' is not allowed!" && exit 0;

        # First push sets the upstream to the given remote - need the latest sync status in case we've reabased
        br_sync_status=$(git isinsyncwithupstream);
        [[ $br_sync_status = 'no_upstream' ]] && br_remote='' || br_remote=$(git config --local branch."$(git symbolic-ref --short HEAD)".remote);
        if [[ $push_flg -eq 1 ]]; then
            if [[ $br_sync_status = 'no_upstream' ]]; then
                git pprint -io "Pushing branch '$this_br' to upstream remote '${1-origin}'";
                git push -u "${1-origin}" "$this_br";
            elif [[ $br_sync_status = 'out_of_sync' ]]; then
                git pprint -io "Pushing branch '$this_br' to upstream remote '$br_remote'";
                git push --force-with-lease;
            elif [[ $br_sync_status = 'in_sync' ]]; then
                git pprint -wo "Nothing to push - '$this_br' is in sync with '$br_remote'!";
            fi && push_to_other_remotes && did_proc_push=1;
        # Check if we should push - only worry about the upstream for now
        elif [[ $br_sync_status = 'out_of_sync' && ($did_br_rply -eq 1 || $did_br_rbi -eq 1) ]]; then
            git pprint -wo "'$this_br' has been previously pushed - syncing with '$br_remote'!";
            git push --force-with-lease && push_to_other_remotes && did_proc_push=1;
        fi && [[ did_proc_push -eq 1 ]] && git pprint -so "bpush|saved succeeded!" || :;
    };
};

bup "$@";
