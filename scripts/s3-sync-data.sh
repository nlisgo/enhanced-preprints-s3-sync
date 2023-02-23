#!/bin/bash
set -e
# example run:
# ./scripts/s3-sync-data.sh data/ s3://elife-epp-data/data

sync_dir=$1
s3=$2
include_pattern=$3

echo "Syncing $sync_dir to $s3..."

if [ -n "$include_pattern" ]; then
    aws s3 sync "$sync_dir" "$s3" --exclude "*" --include "$include_pattern"
else
    aws s3 sync "$sync_dir" "$s3"
fi
