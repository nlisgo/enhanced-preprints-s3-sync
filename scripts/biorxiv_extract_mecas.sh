#!/bin/bash
set -e

# This requires xmllint and macos/bsd sed
# pass the directory of mecas as first param, and output directory as second
# example run:
# ./scripts/biorxiv_extract_mecas.sh biorxiv-mecas/ data/

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
NODE_SCRIPT=$SCRIPT_DIR/biorxiv_fix_xml.js
echo $NODE_SCRIPT

for file in $1/*; do
    tmpDir="/tmp/mecaunzip"
    rm -R $tmpDir || true

    echo $tmpDir

    echo "extracting $file..."
    unzip -q $file -d $tmpDir

    echo "getting article XML path from $tmpDir/manifest.xml ..."
    xmlFile=$(cat $tmpDir/manifest.xml | sed 's/xmlns=".*"//g' | xmllint -xpath 'string(/manifest/item[@type="article"]/instance[@media-type="application/xml"]/@href)' -)


    echo -n "getting doi from $tmpDir/$xmlFile ... "
    doi=$(cat $tmpDir/$xmlFile | sed 's/xmlns=".*"//g' | xmllint -xpath 'string(/article/front/article-meta/article-id)' -)
    echo "'$doi'."

    patchFile="$SCRIPT_DIR/../patches/$doi.patch"
    if [ -f "$patchFile" ]; then
        echo "Applying patch file $patchFile to $tmpDir/$xmlFile"
        patch -p0 -i "$patchFile" "$tmpDir/$xmlFile" || true
    else
        echo "No patch file found for $doi"
    fi

    outputDir="$2/$doi"
    id=$(basename $outputDir)
    uuid=$(basename -s .meca $file)


    echo "creating $outputDir"
    mkdir -p "$outputDir"

    echo "$uuid" > "$outputDir/source.txt"

    echo "cp $tmpDir/$xmlFile to $outputDir/$id.xml..."
    cp "$tmpDir/$xmlFile" "$outputDir/$id.xml"

    echo "and correct some encoda XML issues..."
    # sed -i '' 's|string-name>|name>|g' "$outputDir/$id.xml"  # string-name -> name
    # sed -i '' -E 's|<label>(.*)</label><title>|<title><label>\1</label> |g' "$outputDir/$id.xml" # <label>1</label><title> -> <title><label>1</label>
    # sed -i '' 's|^<label>([[:digit:]\.]*)</label>||g' "$outputDir/$id.xml" # <label>1</label>\n -> *delete it*
    # sed -i '' 's|</table-wrap>|</fig>|g' "$outputDir/$id.xml"  # table-wrap -> figure
    # sed -i '' 's|<table-wrap|<fig|g' "$outputDir/$id.xml"  # table-wrap -> figure
    node $NODE_SCRIPT "$outputDir/$id.xml"

    echo "copy all tif content to $outputDir..."
    cp $tmpDir/content/*.tif "$outputDir/" || true
    cp $tmpDir/content/*.gif "$outputDir/" || true
    cp $tmpDir/content/*.jpg "$outputDir/" || true

    # remove the pdf_url approach when we move away from enhanced-preprints-data
    pdf_url="https://github.com/elifesciences/enhanced-preprints-data/raw/master/data/${doi}/$(basename ${doi}).pdf"

    if curl --output /dev/null --silent --head --fail "$pdf_url"; then
        echo "PDF available for $doi"
        curl -L "$pdf_url" -o "$outputDir/$(basename ${doi}).pdf"
        echo "PDF downloaded to $outputDir/$(basename ${doi}).pdf"
    else
        echo "PDF not available for $doi"
    fi

    # switch to pdf_s3 approach when we move away from enhanced-preprints-data
    # pdf_s3="s3://elife-epp-data/pdf/${doi}/$(basename ${doi}).pdf"

    # aws s3 cp "$pdf_s3" "$outputDir" || true

    # if [ -f "$outputDir/$(basename ${doi}).pdf" ]; then
    #     echo "PDF downloaded to $outputDir/$(basename ${doi}).pdf"
    # else
    #     echo "PDF not found"
    # fi

    echo "cleaning up..."
    rm -R $tmpDir
done
