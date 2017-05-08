#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

make-gitconfig() {
    local alias_body=''
    local alias_name=''
    local base_filename=''
    gitconfig_path=''
    local -r script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    local temp_alias_file=''
    local global_flg=0

    local -r red=$(tput setaf 1)
    local -r grn=$(tput setaf 2)
    local -r org=$(tput setaf 3)
    local -r rst=$(tput sgr0)

    finish() {
        printf "%s==> Cleaning up\n%s" "$(tput setaf 2)" "$(tput sgr0)"
        rm "${gitconfig_path}.bak"
    }
    trap finish EXIT

    cdToScriptPath() {
        cd "$1" || exit
    }

    while getopts ':g' flg; do
        case $flg in
        g)
            global_flg=1;;
        *)
            echo "${red}Invalid option expecting '<-g>'!${rst}";
            exit 1;;
        esac
    done
    shift $((OPTIND - 1))

    cdToScriptPath "$script_path"
    [[ $global_flg -eq 1 ]] && gitconfig_path="$HOME/.gitconfig" || gitconfig_path="${script_path}/.gitconfig"
    [[ $global_flg -eq 1 ]] && printf "%s==> Writing to global gitconfig!\n%s" "${red}" "${rst}"


    # Backup gitconfig
    cp "$gitconfig_path" "${gitconfig_path}.bak"
    printf "%s==> gitconfig backed up\n%s" "${grn}" "${rst}"

    # Make gitconfig
    printf "%s==> Making gitconfig\n%s" "${grn}" "${rst}"

    # Write gitconfig simple aliases
    printf "%s==> Adding simple aliases\n%s" "${grn}" "${rst}"
    chmod +x "${script_path}/config/alias.sh"
    . "${script_path}/config/alias.sh" "$gitconfig_path"
    # Write gitconfig configuration
    printf "%s==> Adding config options\n%s" "${grn}" "${rst}"
    chmod +x "${script_path}/config/config.sh"
    . "${script_path}/config/config.sh" "$gitconfig_path"

    printf "%s==> Adding anonymous function aliases\n%s" "${grn}" "${rst}"

    [[ -z ${1:-} ]] && FILE_PAT="${script_path}/anonymous_functions/**/*.sh" || FILE_PAT="$1"
    for filename in $FILE_PAT; do
        [[ ! -s $filename ]] &&  printf "%s==> $filename is empty - skipping\n%s" "${org}" "${rst}" && continue
        [[ $filename == *"~"* ]] &&  printf "%s==> $filename is WIP - skipping\n%s" "${org}" "${rst}" && continue

        temp_alias_file="${filename%.*}-alias.${filename##*.}"
        # Strip all comments and collapse all whitespace to a single space - leave explicit whitespace escape characters
        grep -E -v "^[[:blank:]]*#"  "$filename" > "$temp_alias_file" && ex +%j -scwq "$temp_alias_file"
        alias_body=$(<"$temp_alias_file")
        rm "$temp_alias_file"

        # Build alias string - remove git- from base filename and concatentate
        base_filename=$(basename "${filename%.*}")
        alias_name=${base_filename#'git-'}
        printf "%s==> $alias_name built\n%s" "${grn}" "${rst}"

        # Let git write anonymous function aliases - will do a better job of escaping
        alias_body="!f() { $alias_body }; f"
        git config --file "$gitconfig_path" "alias.${alias_name}" "$alias_body"

        printf "%s\t==> $alias_name written\n%s" "${grn}" "${rst}"
    done
}

make-gitconfig "$@"
