#!/bin/bash
set -euo pipefail;

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
                git pprint -if "Updating branch \x27$br_point\x27";
                git pull "${2-origin}" "$br_point";
            fi && git checkout -b "$br_name" && git pprint -sf "bnew succeeded!";
        };

        return $?;
    };

    migrate() {
        git bmigrate "$br_name" "$br_point" && {
            if [[ $upd_flg -eq 1 ]]; then
                git bup;
            fi && git pprint -sf "bnew succeeded!";
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
            git pprint -ef "Invalid option expecting \x27<-f|h|r[m][u]>\x27!";
            exit 1;;
        esac
    done;
    shift $((OPTIND - 1));

    [[ -z $br_flg ]] && { git pprint -ef "A flag \x27<-f|h|r>\x27 indicating the kind of branch to create is required!"; exit 1; };

    br_desc=${1:-};
    [[ -z $br_desc ]] && { git pprint -ef "Option \x27-$br_flg\x27 requires an argument like my-new-branch!"; exit 1; };

    br_name=${br_afx}"/${my_intls}/"$(git check-ref-format --branch "$(git trimcompactreplacespace -l "$br_desc" \x27-\x27)");

    if [[ -n $(git branch --list "$br_name") ]]; then
        git pprint -ef "A branch named \x27$br_name\x27 already exists!";
    elif [[ $mgt_flg -eq 1 || -n $(git status --porcelain) ]]; then
        # Handle the dirty working dir
        if [[ -n $(git status --porcelain) ]]; then
            # Don't commit anything to develop or master
            if [[ $this_br = 'develop' || $this_br = 'master' ]]; then
                git pprint -gf "We noticed your working directory is dirty! - changes must be committed to the new branch \x27$br_name\x27 (n) or you may abort (a).\n" | fold -sw 100;
                mgt_act_pat="^[nN]$|^[aA]$";
            else
                git pprint -gf "We noticed your working directory is dirty! Would you like to commit your changes to the new branch $(tput setaf 7)\x27$br_name\x27$(tput setaf 5) (n), this_br branch $(tput setaf 7)\x27$this_br\x27$(tput setaf 5) (c), or you may abort (a).\n" | fold -sw 100;
                mgt_act_pat="^[nN]$|^[cC]$|^[aA]$";
            fi;

            mgt_act=$(git pprint -pd "Default is commit to the the new branch \x27$br_name\x27 (n)?: ") && echo;
            [[ $mgt_act =~ $mgt_act_pat ]] && mgt_act=$(git trim "$mgt_act" | tr '[:upper:]' '[:lower:]') || mgt_act="n";
            [[ $mgt_act = "a" ]] && exit 0;

            if [[ $mgt_act = "c" ]]; then
                git bcm && cob "$@";
            else
                migrate "$@";
            fi;
        else
            git pprint -gf "The number of commits you specify will be moved from \x27$this_br\x27 to the new branch \x27$br_name\x27." | fold -sw 100;
            migrate "$@";
        fi;
    else
        cob "$@";
    fi;
};

bnew "$@";
