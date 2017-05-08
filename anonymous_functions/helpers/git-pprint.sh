#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

RED=$(tput setaf 1);
GRN=$(tput setaf 2);
ORG=$(tput setaf 3);
BLU=$(tput setaf 4);
# Override standard blue if executing on windows
[[ $(git whichos) = 'WIN' ]] && BLU=$(tput setaf 6);
PUR=$(tput setaf 5);
WHT=$(tput setaf 7);
RST=$(tput sgr0);
#UND=$(tput sgr 0 1);
#BLD=$(tput bold);
STYLE_FLG='';
CMD_FLG='';

while getopts ":egipswdof" FLG; do
    case $FLG in
    # Error
    e)
        STYLE_FLG='e';;
    # Guided Experience
    g)
        STYLE_FLG='g';;
    # Info
    i)
        STYLE_FLG='i';;
    # Prompt
    p)
        STYLE_FLG='p';;
    # Success
    s)
        STYLE_FLG='s';;
    # Warning
    w)
        STYLE_FLG='w';;
    # Use read
    d)
        CMD_FLG='d';;
    # Use printf
    f)
        CMD_FLG='f';;
    # Use echo
    o)
        CMD_FLG='o';;
    *)
        echo "$(tput setaf 1)Invalid option expecting '<-e|g|i|p|s[d|o|f]>'!$(tput sgr 0)";
        exit 1;;
    esac
done;
shift $((OPTIND - 1));

STRING=${1:-};
PREFIX=${2:-};
POSTFIX=${3:-};

[[ -z $STYLE_FLG ]] && { echo "${RED}A flag '<-e|g|i|p|s>' indicating the output style is required!${RST}"; exit 1; };
[[ -z $CMD_FLG ]] && { echo "${RED}A flag '<-d|o|f>' indicating the command to use is required!${RST}"; exit 1; };
[[ -z $STRING ]] && { echo "${RED}A string to output is required!${RST}"; exit 1; };

case $STYLE_FLG in
e)
    STRING="${RED}==> $STRING${RST}";;
g)
    STRING="${PUR}==> $STRING${RST}";;
i)
    STRING="${BLU}==> $STRING${RST}";;
p)
    STRING="${WHT}==> $STRING${RST}";;
s)
    STRING="${GRN}==> $STRING${RST}";;
w)
    STRING="${ORG}==> $STRING${RST}";;
esac;

case $CMD_FLG in
d)
    read -p "${PREFIX}${STRING}${POSTFIX}" -r INPUT;
    echo "$INPUT";;
o)
    echo "${PREFIX}${STRING}${POSTFIX}";;
f)
    printf "%s\n" "${PREFIX}${STRING}${POSTFIX}";;
esac;
