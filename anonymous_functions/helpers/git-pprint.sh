#!/bin/bash
set -euo pipefail;

pprint() {
    local -r red=$(tput setaf 1);
    local -r grn=$(tput setaf 2);
    local -r org=$(tput setaf 3);
    [[ $(git whichos) != 'WIN' ]] && local -r blu=$(tput setaf 4);
    # Override standard blue if executing on windows
    [[ $(git whichos) = 'WIN' ]] && local -r blu=$(tput setaf 6);
    local -r pur=$(tput setaf 5);
    local -r wht=$(tput setaf 7);
    local -r rst=$(tput sgr0);
    #UND=$(tput sgr 0 1);
    #BLD=$(tput bold);
    local style_flg='';
    local cmd_flg='';

    while getopts ':egipswdf' flg; do
        case $flg in
        # Error
        e)
            style_flg='e';;
        # Guided Experience
        g)
            style_flg='g';;
        # Info
        i)
            style_flg='i';;
        # Prompt
        p)
            style_flg='p';;
        # Success
        s)
            style_flg='s';;
        # Warning
        w)
            style_flg='w';;
        # Use read
        d)
            cmd_flg='d';;
        # Use printf
        f)
            cmd_flg='f';;
        *)
            printf  "%b\n" "${red}Invalid option expecting \x27<-e|g|i|p|s[d|f]>\x27!${rst}";
            exit 1;;
        esac
    done;
    shift $((OPTIND - 1));

    local string=${1:-};
    local -r prefix=${2:-};
    local -r postfix=${3:-};

    [[ -z $style_flg ]] && { printf "%b\n" "${red}A flag \x27<-e|g|i|p|s>\x27 indicating the output style is required!${rst}"; exit 1; };
    [[ -z $cmd_flg ]] && { printf "%b\n" "${red}A flag \x27<-d|f>\x27 indicating the command to use is required!${rst}"; exit 1; };
    [[ -z $string ]] && { printf "%b\n" "${red}A string to output is required!${rst}"; exit 1; };

    case $style_flg in
    e)
        string="${red}==> $string${rst}";;
    g)
        string="${pur}==> $string${rst}";;
    i)
        string="${blu}==> $string${rst}";;
    p)
        string="${wht}==> $string${rst}";;
    s)
        string="${grn}==> $string${rst}";;
    w)
        string="${org}==> $string${rst}";;
    esac;

    case $cmd_flg in
    d)
        read -p "$(printf "%b\n" "${prefix}${string}${postfix}")" -r input;
        printf "%s" "$input";;
    f)
        printf "%b\n" "${prefix}${string}${postfix}";;
    esac;
};

pprint "$@";
