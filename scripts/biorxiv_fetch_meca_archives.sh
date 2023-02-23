#!/bin/bash
set -e
# example run:
# ./scripts/biorxiv_fetch_meca_archives.sh biorxiv-mecas/

output_dir=$1

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

while read -r line; do
    $SCRIPT_DIR/biorxiv_fetch_meca_archive.sh "$line" $output_dir
done < biorxiv-mecas.txt
