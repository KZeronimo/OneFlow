#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

cdToScriptPath() {
  cd "$1"
}

GRN=$(tput setaf 2)
ORG=$(tput setaf 3)
RST=$(tput sgr0)

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cdToScriptPath "$SCRIPT_PATH"

# Backup gitconfig
declare -r GITCONFIG_PATH="${SCRIPT_PATH}/.gitconfig"
cp "$GITCONFIG_PATH" "${GITCONFIG_PATH}.bak"
printf "%s==> gitconfig backed up\n%s" "${GRN}" "${RST}"

# Make gitconfig
printf "%s==> Making gitconfig\n%s" "${GRN}" "${RST}"

# Write simple gitconfig options
printf "%s==> Adding simple aliases\n%s" "${GRN}" "${RST}"
chmod +x "${SCRIPT_PATH}/config/alias.sh"
. "${SCRIPT_PATH}/config/alias.sh"
printf "%s==> Adding config options\n%s" "${GRN}" "${RST}"
chmod +x "${SCRIPT_PATH}/config/config.sh"
. "${SCRIPT_PATH}/config/config.sh"

printf "%s==> Adding anonymous function aliases\n%s" "${GRN}" "${RST}"
[[ -z "$*" ]] && FILE_PAT="${SCRIPT_PATH}/anonymous_functions/**/*.sh" || FILE_PAT="$1"
for filename in $FILE_PAT; do
    [[ ! -s $filename ]] &&  printf "%s==> $filename is empty - skipping\n%s" "${ORG}" "${RST}" && continue
    [[ $filename == *"~"* ]] &&  printf "%s==> $filename is WIP - skipping\n%s" "${ORG}" "${RST}" && continue

    TEMP_ALIAS_FILE="${filename%.*}-alias.${filename##*.}"
    # Strip all comments and collapse all whitespace to a single space - leave explicit whitespace escape characters
    grep -E -v "^[[:blank:]]*#"  "$filename" > "$TEMP_ALIAS_FILE" && ex +%j -scwq "$TEMP_ALIAS_FILE"
    ALIAS_BODY=$(<"$TEMP_ALIAS_FILE")
    rm "$TEMP_ALIAS_FILE"

    # Escape double quotes
    ALIAS_BODY="${ALIAS_BODY//\"/\\\"}"

    # Build alias string - remove git- from base filename and concatentate
    BASE_FILENAME=$(basename "${filename%.*}")
    ALIAS_NAME=${BASE_FILENAME#'git-'}
    ALIAS="${ALIAS_NAME} = \"!f() { $ALIAS_BODY }; f\""
    printf "%s==> $ALIAS_NAME built\n%s" "${GRN}" "${RST}"

    # Find the line number of the alias in our gitconfig - fallback to the [alias] section if not found
    if grep -q "\b${ALIAS_NAME} = \"!f()" "$GITCONFIG_PATH"; then
        LN=$(grep -n "\b${ALIAS_NAME} = \"!f()" "$GITCONFIG_PATH" | cut -f1 -d:)
        ALIAS="$(printf "\t")${ALIAS}"
        printf "%s\t==> Replace existing $ALIAS_NAME - (LN: ${LN})\n%s" "${GRN}" "${RST}"
    else
        LN=$(grep -n "^\b\[alias\]" "$GITCONFIG_PATH" | cut -f1 -d:);
        ALIAS="$(printf "[alias]\n\t")${ALIAS}"
        printf "%s\t==> New alias - inserting $ALIAS_NAME - (LN: ${LN})\n%s" "${ORG}" "${RST}"
    fi

    OUTPUT="$(ln=$LN alias=$ALIAS awk 'NR==ENVIRON["ln"] {$0=ENVIRON["alias"]} 1' "$GITCONFIG_PATH")"
    echo "$OUTPUT" > "$GITCONFIG_PATH"
    printf "%s\t==> $ALIAS_NAME written\n%s" "${GRN}" "${RST}"
done

trap finish EXIT

finish() {
    # Leave Autounattend.xml ready for next use
    printf "%s==> Cleaning up\n%s" "${GRN}" "${RST}"
    rm "${GITCONFIG_PATH}.bak"
}
