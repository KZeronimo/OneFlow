#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

bnew() {
    local -r this_br=$(git symbolic-ref --short HEAD);
    local -r my_intls=$(git config user.initials);
    local br_afx='';
    local br_desc='';
    local br_name='';
    local br_point='';
    local mgt_act='';
    local mgt_act_pat='';
    local br_flg='';
    local mgt_flg=0;
    local upd_flg=0;

    cob() {
        if [[ $this_br != "$br_point" ]]; then
            git checkout "$br_point";
        fi && {
            if [[ $upd_flg -eq 1 ]]; then
                git pprint -io "Updating branch '$br_point'";
                git pull "${2-origin}" "$br_point";
            fi && git checkout -b "$br_name" && git pprint -so "bnew succeeded!";
        };

        return $?;
    };

    migrate() {
        git bmigrate "$br_name" "$br_point" && {
            if [[ $upd_flg -eq 1 ]]; then
                git bup;
            fi && git pprint -so "bnew succeeded!";
            };

        return $?;
    };

    # Process command options
    while getopts ':fhrum' flg; do
        case $flg in
        f)
            if [[ -z $br_flg ]]; then
                br_flg=$flg;
                br_point='develop';
                br_afx=$(git config workflow.featureaffix);
            fi;;
        h)
            if [[ -z $br_flg ]]; then
                br_flg=$flg;
                br_point='master';
                br_afx=$(git config workflow.hotfixaffix);
            fi;;
        r)
            if [[ -z $br_flg ]]; then
                br_flg=$flg;
                br_point='develop';
                br_afx=$(git config workflow.releaseaffix);
            fi;;
        m)
            mgt_flg=1;;
        u)
            upd_flg=1;;
        *)
            git pprint -eo "Invalid option expecting '<-f|h|r[m][u]>'!";
            exit 1;;
        esac
    done;
    shift $((OPTIND - 1));

    [[ -z $br_flg ]] && { git pprint -eo "A flag '<-f|h|r>' indicating the kind of branch to create is required!"; exit 1; };

    br_desc=${1:-};
    [[ -z $br_desc ]] && { git pprint -eo "Option '-$br_flg' requires an argument like my-new-branch!"; exit 1; };

    br_name=${br_afx}"/${my_intls}/"$(git check-ref-format --branch "$(git trimcompactreplacespace -l "$br_desc" '-')");

    if [[ -n $(git branch --list "$br_name") ]]; then
        git pprint -eo "A branch named '$br_name' already exists!";
    elif [[ $mgt_flg -eq 1 || -n $(git status --porcelain) ]]; then
        # Handle the dirty working dir
        if [[ -n $(git status --porcelain) ]]; then
            # Don't commit anything to develop or master
            if [[ $this_br = 'develop' || $this_br = 'master' ]]; then
                git pprint -gf "We noticed your working directory is dirty! - changes must be committed to the new branch '$br_name' (n) or you may abort (a).\n" | fold -sw 100;
                mgt_act_pat="^[nN]$|^[aA]$";
            else
                git pprint -gf "We noticed your working directory is dirty! Would you like to commit your changes to the new branch $(tput setaf 7)'$br_name'$(tput setaf 5) (n), this_br branch $(tput setaf 7)'$this_br'$(tput setaf 5) (c), or you may abort (a).\n" | fold -sw 100;
                mgt_act_pat="^[nN]$|^[cC]$|^[aA]$";
            fi;

            mgt_act=$(git pprint -pd "Default is commit to the the new branch '$br_name' (n)?: ") && echo;
            [[ $mgt_act =~ $mgt_act_pat ]] && mgt_act=$(git trim "$mgt_act" | tr '[:upper:]' '[:lower:]') || mgt_act="n";
            [[ $mgt_act = "a" ]] && exit 0;

            if [[ $mgt_act = "c" ]]; then
                git bcm && cob "$@";
            else
                migrate "$@";
            fi;
        else
            git pprint -gf "The number of commits you specify will be moved from '$this_br' to the new branch '$br_name'." | fold -sw 100;
            migrate "$@";
        fi;
    else
        cob "$@";
    fi;
};

bnew "$@";
