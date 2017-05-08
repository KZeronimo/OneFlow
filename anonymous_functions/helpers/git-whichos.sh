#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

TEMP=$(uname -s);
declare -r OS=$TEMP;
OS_FAMILY='';

if [[ ${OS:0:6} = 'Darwin' ]]; then
    OS_FAMILY='OSX';
elif [[ ${OS:0:5} = 'Linux' ]]; then
   OS_FAMILY='LINUX';
elif [[ ${OS:0:10} = 'MINGW32_NT' ]]; then
    OS_FAMILY='WIN';
elif [[ ${OS:0:10} = 'MINGW64_NT' ]]; then
    OS_FAMILY='WIN';
fi;

echo "$OS_FAMILY";
