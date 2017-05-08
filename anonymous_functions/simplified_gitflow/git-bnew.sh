#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

TEMP=$(git symbolic-ref --short HEAD);
declare -r THIS_BR=$TEMP;
TEMP=$(git config user.initials);
declare -r MY_INTLS=$TEMP;
BR_AFX="";
BR_POINT="";
BR_NAME="";
BR_FLG="";
MGT_FLG=0;
UPD_FLG=0;

cob() {
    [[ $THIS_BR != "$BR_POINT" ]] && git checkout "$BR_POINT" && {
        if [[ $UPD_FLG -eq 1 ]]; then
            git pprint -io "Updating branch '$BR_POINT'!";
            git pull "${2-origin}" "$BR_POINT" && git checkout -b "$BR_NAME" && git pprint -so "bnew succeeded!";
        else
            git checkout -b "$BR_NAME" && git pprint -so "bnew succeeded!";
        fi; };
};

migrate() {
    git bmigrate "$BR_NAME" "$BR_POINT" && {
        if [[ $UPD_FLG -eq 1 ]]; then
            git bup && git pprint -so "bnew succeeded!";
        else
            git pprint -so "bnew succeeded!";
        fi; };
};

# Process command options
while getopts ":fhrum" FLG; do
    case $FLG in
    f)
        BR_AFX=$(git config workflow.featureaffix);
        [[ -z $BR_FLG ]] && BR_FLG=$FLG;
        BR_POINT='develop';;
    h)
        BR_AFX=$(git config workflow.hotfixaffix);
        [[ -z $BR_FLG ]] && BR_FLG=$FLG;
        BR_POINT='master';;
    r)
        BR_AFX=$(git config workflow.releaseaffix);
        [[ -z $BR_FLG ]] && BR_FLG=$FLG;
        BR_POINT='develop';;
    m)
        MGT_FLG=1;;
    u)
        UPD_FLG=1;;
    *)
        git pprint -eo "Invalid option expecting '<-f|h|r[m][u]>'!";
        exit 1;;
    esac
done;
shift $((OPTIND - 1));

BR_DESC=${1:-};

[[ -z $BR_FLG ]] && { git pprint -eo "A flag '<-f|h|r>' indicating the kind of branch to create is required!"; exit 1; };
[[ -z $BR_DESC ]] && { git pprint -eo "Option '-$BR_FLG' requires an argument like my-new-branch!$"; exit 1; };

BR_NAME=${BR_AFX}"/${MY_INTLS}/"$(git check-ref-format --branch "$(git trimcompactreplacespace -l "${1}" '-')");

if [[ -n $(git branch --list "$BR_NAME") ]]; then
    git pprint -eo "A branch named '$BR_NAME' already exists!";
elif [[ $MGT_FLG -eq 1 || -n $(git status --porcelain) ]]; then
    # Handle the dirty working dir
    if [[ -n $(git status --porcelain) ]]; then
        MGT_ACT_PAT="";

        # Don't commit anything to develop or master
        if [[ $THIS_BR = 'develop' || $THIS_BR = 'master' ]]; then
            git pprint -gf "We noticed your working directory is dirty! - changes must be committed to the new branch '$BR_NAME' (n) or you may abort (a).\n" | fold -sw 100;
            MGT_ACT_PAT="^[nN]$|^[aA]$";
        else
            git pprint -gf "We noticed your working directory is dirty! Would you like to commit your changes to the new branch $(tput setaf 7)'$BR_NAME'$(tput setaf 5) (n), THIS_BR branch $(tput setaf 7)'$THIS_BR'$(tput setaf 5) (c), or you may abort (a).\n" | fold -sw 100;
            MGT_ACT_PAT="^[nN]$|^[cC]$|^[aA]$";
        fi;

        MGT_ACT=$(git pprint -pd "Default is commit to the the new branch '$BR_NAME' (n)?: ") && echo;
        [[ $MGT_ACT =~ $MGT_ACT_PAT ]] && MGT_ACT=$(git trim "$MGT_ACT" | tr '[:upper:]' '[:lower:]') || MGT_ACT="n";
        [[ $MGT_ACT = "a" ]] && exit 0;

        if [[ $MGT_ACT = "c" ]]; then
            git bcm && cob "$@";
        else
            migrate "$@";
        fi;
    else
        git pprint -gf "The number of commits you specify will be moved from '$THIS_BR' to the new branch '$BR_NAME'." | fold -sw 100;
        migrate "$@";
    fi;
else
    cob "$@";
fi;
