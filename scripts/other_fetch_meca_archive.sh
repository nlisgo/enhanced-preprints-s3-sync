#!/bin/bash
set -e
# pass the s3 path of meca as first param, and output directory as second
# example run:
# ./scripts/other_fetch_meca_archive.sh s3://elife-epp-data/meca/3e6bc52a-6bf6-1014-8174-b177e41bc9d5.meca other-mecas/

s3source=$1
output_dir=$2

echo "fetching $s3source to $output_dir...";

aws s3 cp --request-payer requester "$s3source" "$output_dir/"
