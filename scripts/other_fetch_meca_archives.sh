#!/bin/bash
set -e
# example run:
# ./scripts/other_fetch_meca_archives.sh s3://elife-epp-data/meca other-mecas/

s3=$1
output_dir=$2

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

while read -r line; do
    $SCRIPT_DIR/other_fetch_meca_archive.sh "$s3/$line" $output_dir
done < other-mecas.txt
