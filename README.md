# s3 data folder

- `s3://elife-epp-data/meca` we upload non-biorxiv meca files here in a single folder.
- `s3://elife-epp-data/pdf` we upload all manuscript pdfs here `s3://elife-epp-data/pdf/[doi-prefix]/[doi-suffix]/[doi-suffix].pdf`
- `s3://elife-epp-data/data` use this documentation to service this folder. Should contain nothing that can't be recreated.

# Add biorxiv manuscript

Add entry in `./biorxiv-mecas.txt` which is a doi suffix per line.

```
2020.07.27.223354
2021.06.21.449261
2021.09.24.461751
2021.11.12.468444
2022.03.04.482974
...
```

When pdf available deposit in `s3://elife-epp-data/pdf/[doi-prefix]/[doi-suffix]/[doi-suffix].pdf`.

# Add other manuscript

Add entry in `./biorxiv-mecas.txt` which is a meca filename per line.

When pdf available deposit in `s3://elife-epp-data/pdf/[doi-prefix]/[doi-suffix]/[doi-suffix].pdf`.

## Process biorxiv manuscripts

```
./scripts/biorxiv_fetch_meca_archives.sh biorxiv-mecas/
./scripts/biorxiv_extract_mecas.sh biorxiv-mecas/ data/
```

The `biorxiv_fetch_meca_archives.sh` will fetch all the manuscript dois listed in `./biorxiv-mecas.txt` file. Add additonal biorxiv manuscripts by extending the doi's in that list.

The `./scripts/biorxiv_extract_mecas.sh` script extracts the meca file and prepares a temp folder with the manuscript xml. If a patch is found with the same doi as the manuscript being processed in the `patches/` folder, the patch will be applied. Some modifications are made to the xml and the tif and gif files are prepared. Then the pdf files are searched for in the `s3://elife-epp-data/pdf` folder and downloaded if found to the temp folder. The prepared folder is then moved to the output dir as specified when the script is called.

### Check against enhanced-preprints-data prior to migration

Before running `./scripts/biorxiv_extract_mecas.sh` ensure we can access the pdf files currently stored in `enhanced-preprints-data`.

```
./scripts/s3-sync-data.sh [local path to enhanced-preprints-data]/data s3://elife-epp-data/pdf "*.pdf"
```

In order to verify that the data folder is the same as what we currently have in `enhanced-preprints-data`, clone that repo locally and perform a diff on the prepared data folder from running the above scripts with the files pulled down from `enhanced-preprints-data` git repo.

For example (no output indicates the folders match):
```
diff -r -r ./data ../enhanced-preprints-data/data
```

## Process other meca

```
./scripts/other_fetch_meca_archives.sh s3://elife-epp-data/meca other-mecas/
./scripts/other_extract_mecas.sh other-mecas/ data/
```

The `other_fetch_meca_archives.sh` will fetch all the meca files listed in `./biorxiv-mecas.txt` file from the s3 bucket. Add additonal manuscripts by extending the list and posting the meca file in `s3://elife-epp-data/meca`.

The `./scripts/other_extract_mecas.sh` script extracts the meca file and prepares a temp folder with the manuscript xml. The tif and gif files are prepared. Then the pdf files are searched for in the `s3://elife-epp-data/pdf` folder and downloaded if found to the temp folder. The prepared folder is then moved to the output dir as specified when the script is called.

## Sync data folder to s3

```
./scripts/s3-sync-data.sh data/ s3://elife-epp-data/data
```
