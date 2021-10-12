# Readme: About this folder

Manually patching the `main` branch's data tables with entries from the `2.0-Fiction` branch. Since the table's structures have changed, as well as their location inside the repo. We need to go beyond git patches using [daff](https://paulfitz.github.io/daff-doc/spec.html).  


Each table that requires a patch has its own subfolder below, with the original data-tables marked as `_lit` and `_main` respectively.

## Patch

The file name of the patches, stored inside the `patch/` subfolder are meaning full. We use `csv` format for the patch files for easier manual inspection. Patch filenames are constructed by combining:

- Table Name (e.g. `Act`)
- patch designator `_p`
- followed by a number
- followed by `a` for patches where `_lit` was daffed against `_main`, and `b` in the reverse case.

E.g. `Act_p5a.csv`

Some manual intervention is still required, so the steps necessary for reproduction are listed below for each table. In principle, we focus on *insertions* from `_lit` into `_main` . To generate the patch files.

Ignored columns will receive `NULL` entries in the output table, which can be cleaned up. In general, no `a` type patch should delete columns from `main` tables, the reverse can happen. The patch that was used to generate the output should be stored and committed into the repo. Lastly, the data from ignore columns might need to be added in a separate patch to another target table. 

## Out

The output approaches the form of the new table for the `main` branch, but can still require manual cleanup.

### Act

`source_status` has been deprecated, `site_information` is unique to `main`

```shell
daff diff --act insert --ignore site_information --ignore source_status --ignore id_lang Act_main.csv Act_lit.csv > patch/Act_p5a.csv
daff patch Act_main.csv patch/Act_p5a.csv > out/Act_p5.csv
```

### ArtWork

Creator and commentary need to go to `works.csv`

```shell
daff diff --act insert --ignore creator --ignore commentary ArtWork_main.csv ArtWork_lit.csv > patch/ArtWork_p2a.csv
daff patch ArtWork_main.csv patch/ArtWork_p2a.csv > out/ArtWork_p2.csv
```

### Institution

`commentary` contains no entries, the column moved to works

```shell
daff diff --act insert --ignore commentary Institution_main.csv Institution_lit.csv > patch/Institution_p2a.csv
daff patch Institution_main.csv patch/Institution_p2a.csv > out/Institution_p2.csv
```


## Cleanup

- Create new primary keys according to new `id` scheme.
- Replace old `id` secondary keys with new ones.
- Delete all `NULL` strings.
- sort by primary key (and lang column where present)

### Act

- extend structural `id_lang` to `lit` entries
- check `site_information` for `lit` entries

### ArtWork

- create primary keys for new art works in `work.csv` 

### Institution

- Delete `I0004`, `I0006`, and `I0007` additions from patched output.
- refactor the notes "fictional" this should be captured on  `Agent.csv` only, double check whats going on there.
