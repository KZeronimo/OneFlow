#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

LWR_FLG=0;
UPR_FLG=0;

# Process command options
while getopts ":lu" FLG; do
    case $FLG in
    l)
        LWR_FLG=1;;
    u)
        UPR_FLG=1;;
    *)
        git pprint -eo "Invalid option expecting '[-l|u]'!";
        exit 1;;
    esac
done;
shift $((OPTIND - 1));

INPUT=${1:-};
PAT=${2:-};

[[ -z $INPUT ]] && { git pprint -eo "A string to operate on is required!"; exit 1; };
[[ -z $PAT ]] && { git pprint -eo "A relacement string is required!"; exit 1; };

PAT='s/ /'"$PAT"'/g';
git trim "$INPUT" | tr -s ' ' |

if [[ LWR_FLG -eq 1 ]]; then
    tr '[:upper:]' '[:lower:]' | sed -e "$PAT";
elif [[ UPR_FLG -eq 1 ]]; then
    tr '[:lower:]' '[:upper:]' | sed -e "$PAT";
else
    sed -e "$PAT";
fi;
