#!/bin/bash
set -e

# This requires xmllint and macos/bsd sed
# pass the directory of mecas as first param, and output directory as second
# example run:
# ./scripts/other_extract_mecas.sh other-mecas/ data/

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

    outputDir="$2/$doi"
    id=$(basename $outputDir)
    uuid=$(basename -s .meca $file)


    echo "creating $outputDir"
    mkdir -p "$outputDir"

    echo "$uuid" > "$outputDir/source.txt"

    echo "cp $tmpDir/$xmlFile to $outputDir/$id.xml..."
    cp "$tmpDir/$xmlFile" "$outputDir/$id.xml"

    echo "copy all tif content to $outputDir..."
    cp $tmpDir/content/*.tif "$outputDir/" || true
    cp $tmpDir/content/*.gif "$outputDir/" || true

    pdf_s3="s3://elife-epp-data/pdf/${doi}/$(basename ${doi}).pdf"

    aws s3 cp "$pdf_s3" "$outputDir" || true

    if [ -f "$outputDir/$(basename ${doi}).pdf" ]; then
        echo "PDF downloaded to $outputDir/$(basename ${doi}).pdf"
    else
        echo "PDF not found"
    fi

    echo "cleaning up..."
    rm -R $tmpDir
done
