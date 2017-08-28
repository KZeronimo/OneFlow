#!/bin/bash
set -euo pipefail;

whichos() {
    local -r OS=$(uname -s);
    local os='';

    if [[ ${OS:0:6} = 'Darwin' ]]; then
        os='OSX';
    elif [[ ${OS:0:5} = 'Linux' ]]; then
        os='LINUX';
    elif [[ ${OS:0:10} = 'MINGW32_NT' ]]; then
        os='WIN';
    elif [[ ${OS:0:10} = 'MINGW64_NT' ]]; then
        os='WIN';
    fi;

    printf "%s\n" "$os";
};

whichos;
