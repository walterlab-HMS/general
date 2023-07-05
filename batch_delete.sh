#!/bin/bash

# Check if the input file is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

# Check if the input file exists
if [ ! -f "$1" ]; then
    echo "File '$1' not found."
    exit 1
fi

# Read each name from the input file
while IFS= read -r name; do
    # Find files matching the name and prompt for deletion
    name=$(echo "$name" | tr -d '[:space:]')
     # Check if the length of name is less than 10 and skip it
    if [ ${#name} -lt 10 ]; then
        echo "Name '$name' is less than 10 characters. Skipping..."
        continue
    fi

    echo "Searching for files with '$name' in their name..."
    files=$(find . -type f -name "*$name*")
    if [ -z "$files" ]; then
        echo "No files found with '$name' in their name."
        continue
    fi

    echo "$files"
    for file in $files; do
        rm -rv "$file"
    done
done < "$1"