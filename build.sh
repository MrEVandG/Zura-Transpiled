#!/bin/sh

# Variables
ZIG_OBJ="zig build-obj"
ZIG_EXE="zig build-exe"
SRC_PATH="src"
EXE_NAME="zura"
OBJ_NAME="zura.o"
OBJ_PATH="obj"

# ANSI escape codes for colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper Functions
print_progress_bar() {
    local iteration=$1
    local total=$2
    local prefix=$3
    local suffix=$4
    local decimals=$5
    local length=$6
    local fill=$7

    local percent=$(awk "BEGIN { pc=100*${iteration}/${total}; i=int(pc); print (pc-i<0.5)?i:i+1 }")
    local filled_length=$(awk "BEGIN { fl=${length}*${iteration}/${total}; i=int(fl); print (fl-i<0.5)?i:i+1 }")
    local bar=$(printf "%-${filled_length}s" "${fill}")
    bar=${bar// /"${fill}"}
    local spaces=$(printf "%-$((length-filled_length))s")

    echo -e "\r${prefix} [${GREEN}${bar}${NC}${spaces}] ${percent}% ${suffix}"
}

generate_object_file() {
    $ZIG_OBJ "$file"
    mv $(find . -name "*.o") "$OBJ_PATH" > /dev/null 2>&1
    rm -rf $(find . -name "*.o.o") > /dev/null 2>&1
}

clean() {
    echo "Cleaning..."
    rm -rf "$EXE_NAME"
    rm -rf "$OBJ_NAME"
    rm -rf "$OBJ_PATH"
    echo "Cleaned"
}

linux() {
    mkdir -p "$OBJ_PATH" # Create the obj directory if it doesn't exist
    SOURCE_FILES=$(find "$SRC_PATH" -name "*.zig")
    total_files=$(echo "$SOURCE_FILES" | wc -l)
    current_file=0

    # Compile each source file to object files
    for file in $SOURCE_FILES; do
        current_file=$((current_file + 1))
        print_progress_bar "$current_file" "$total_files" "Building zura" "(${RED}$file${NC})" 0 30 "#"
        generate_object_file "$file" 
    done

    # Collect all object files and specify them for linking
    # zig build-exe .\tiny-hello.zig -O ReleaseSmall -fstrip -fsingle-threaded
    OBJ_FILES=$(find "$OBJ_PATH" -name "*.o") 
    $ZIG_EXE $OBJ_FILES -fstrip -fsingle-threaded --name "$EXE_NAME"
    
    echo -e "\nBuild for Linux completed."
}


# Main script
if [ "$1" = "clean" ]; then
    clean
elif [ "$1" = "linux" ]; then
    linux
else
    echo "Usage: $0 [clean | linux ]"
    exit 1
fi
