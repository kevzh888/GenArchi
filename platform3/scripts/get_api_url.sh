#!/bin/bash

# Check if exactly two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <file_path> <new_s3_url>"
    exit 1
fi

# Assign arguments to variables
file_path=$1
new_s3_url=$2

# Use sed to replace the second line of the file with the new S3 URL
# -i'' edits the file in place
sed -i'' "2c\const s3Url = '$new_s3_url'" "$file_path"

echo "Replaced second line in $file_path with const s3Url = '$new_s3_url'"
