#!/usr/bin/env bash

HIAB_SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# return 0 if array (i.e. x=() ) exists, otherwise return 1
array-exists() { declare -p "$1" &> /dev/null; }

# create and output path to a temporary file - like mktemp
# adds temporary file to CLEANUP_FILES for automatic cleanup
#
#   my_tmpfile=$(add-tmpfile)
#   echo "hello world" > "$my_tmpfile"
#
add-tmpfile() {
    local tmpf
    tmpf="$(mktemp)"
    if ! array-exists CLEANUP_FILES; then CLEANUP_FILES=(); fi
    CLEANUP_FILES+=("$tmpf")
    echo "$tmpf"
}

add-tempfile() { add-tmpfile; }


{ ! array-exists HIAB_LIB_LOADED || ! array-exists HIAB_LIBS ; } && source "${HIAB_SCRIPTS_DIR}/HIAB_libs.sh" || true

