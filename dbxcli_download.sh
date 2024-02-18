#!/bin/bash

filenames_to_keep=''

while getopts "f:" opt; do
  case $opt in
    f)
      filenames_to_keep=$OPTARG
      echo "Argument supplied: $filenames_to_keep";;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

shift $((OPTIND -1))

dbx_folder_name=$1
dest_name=$2
pattern=$3

# Check if destination directory exists, create it if it doesn't
if [ ! -d "$dest_name" ]; then
    mkdir -p "$dest_name"
fi

# Retrieve a list of files from the Dropbox folder
dbx_files=$(dbxcli ls "$dbx_folder_name" | tr -s [:space:] "\n")
matching_dbx_files=()

# Filter files based on the provided list (if any)
if [ -n "$filenames_to_keep" ]; then
    while read -r line; do
        line="${line%"${line##*[![:space:]]}"}" # Trim trailing whitespace
        match=$(echo "$dbx_files" | grep "$line")
        if [ -n "$match" ]; then
            readarray files <<< "$match"
            matching_dbx_files+=("${files[@]}")
        fi
    done < "$filenames_to_keep"
else
    readarray files <<< "$dbx_files"
    matching_dbx_files=("${files[@]}")
fi

# Change to the destination directory
cd "$dest_name" || exit

# Download only files that match the pattern and are not already present
for f in "${matching_dbx_files[@]}"; do
    filename=$(basename "$f")
    if [[ "$filename" == $pattern && ! -f "$filename" ]]; then
        echo "getting $f"
        ~/bin/dbxcli get $f
    fi
done
