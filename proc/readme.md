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

### Location and Place

Rename:  `Location.`:
-  `loc_id` -> `old_id`
-  `loc_name` -> `space_name`
-  `loc_name_lang` -> `name_lang`

Rename 'Place.`:
-  `place_id` -> `old_id`
-  `place_name` -> `space_name`

to match `Space.csv`.

```shell
daff diff --act insert Space_main.csv Location_lit.csv > patch/Space_p4a.csv
daff diff --act insert Space_main.csv Place_lit.csv > patch/Space_p5a.csv
```

Replace all `---` action column entries with `...` in both patch tables, then

```shell
daff patch Space_main.csv patch/Space_p4a.csv > out/Space_p4.csv
daff patch out/Space_p4.csv patch/Space_p5a.csv > out/Space_p5.csv
```

### Narrative Position

New file from `lit` branch, simple copy to target.

### Person

Ignore rustication columns, it is it's own table, but check entries against `Rustication.csv` first.

```shell
daff diff --act insert Person_main.csv Person_lit.csv > patch/Person_p1a.csv
daff diff --act insert --ignore rustication_start --ignore rustication_end --ignore place_of_rust --ignore alt_name_lang Person_main.csv Person_lit.csv > patch/Person_p2a.csv
```

Manually remove Lines 4-38, and then new lines 9-18 these contain false positives (such as `P0063`), keep the reordered `AG106` and all new entries with `P0850` or higher. Then apply patch:

```shell
daff patch Person_main.csv patch/Person_p2a.csv > out/Person_p2.csv
```

We also need to create main entries for `Agents`. Copy and rename `Person_lit.csv` -> `Agent_lit.csv`. On `Agent_lit` rename: `person_id` -> `old_id`

```shell
daff diff --act insert --id old_id --ignore family_name --ignore first_name --ignore sex --ignore rustication --ignore rustication_start --ignore rustication_end --ignore place_of_rust --ignore birthyear --ignore deathyear --ignore alt_name --ignore alt_name_lang --ignore place_of_birth --ignore social_position --ignore narrative_age --ignore neibu_access --ignore source_1 --ignore page_1 --ignore source_2 --ignore page_2 --ignore fictionality --ignore narrative_status Agent_main.csv Agent_lit.csv > patch/Agent_p4a.csv
```

Note: use p4a to later filter `en` names?

```shell
daff diff --act insert --id old_id --ignore family_name --ignore first_name --ignore sex --ignore name_lang --ignore rustication --ignore rustication_start --ignore rustication_end --ignore place_of_rust --ignore birthyear --ignore deathyear --ignore alt_name --ignore alt_name_lang --ignore place_of_birth --ignore social_position --ignore narrative_age --ignore neibu_access --ignore source_1 --ignore page_1 --ignore source_2 --ignore page_2 --ignore fictionality --ignore narrative_status Agent_main.csv Agent_lit.csv > patch/Agent_p5a.csv
```

Replace all `---` action column entries with `...` in both patch tables

Replace rows `Agent.p4a_5` - `Agent.p4a_1300` (these are just the bilingual insertions) with
`...,...,...,...,...,...,...,...,...,...,...`

patch Agent:

```shell
daff patch Agent_main.csv patch/Agent_p4a.csv > out/Agent_p4.csv
```

### PrimarySource

`PrimarySource` and `SecondarySource`  share the same structure, therefore we can run the same commands on each table.
As with  `ArtWork`, `Source.author`, `Source.commentary`, `Source.fictionality`, `SecondarySource.main_narrator` need to go to `work.csv`. 

```shell
daff diff --act insert --ignore author --ignore commentary PrimarySource_main.csv PrimarySource_lit.csv > patch/Primary_p2a.csv 

daff diff --act insert --ignore author --ignore commentary --ignore main_narrator SecondarySource_main.csv SecondarySource_lit.csv > patch/Secondary_p3a.csv 
```

Patch Source

```shell
daff patch SecondarySource_main.csv patch/Secondary_p2a.csv > out/SecondarySource_p2.csv

daff patch SecondarySource_main.csv patch/Secondary_p3a.csv > out/SecondarySource_p3.csv
```

## Cleanup

- Create new primary keys according to new `id` scheme.
- Replace old `id` secondary keys with new ones.
- Delete all `NULL` strings.
- primary sort by ID and secondary by lang

### Act_p

- extend structural `id_lang` to `lit` entries
- check `site_information` for `lit` entries

### ArtWork_p

- create primary keys for new art works in `work.csv` 

### Institution_p

- Delete `I0004`, `I0006`, and `I0007` additions from patched output.
- refactor the notes "fictional" this should be captured on  `Agent.csv` only, double check whats going on there.

### Space_p

- more careful handling of `NULL` entries necessary, also check for unknown place/location id

### Agent_p

- delete duplicate old_id before proceeding with regular cleanup steps
- cleanup (delete) `Agent.name_lang` column
- ensure that `Person_lit.ficionality` column data is not lost in new system (need to decide where to put it)

### NarrativePosition_p

- update csv schema and data-dictionary for narrative position table.

### Primary- / SecondarySource_p

- sort first lots of dubious entries
- Check `PS00207` which should be unknown work?
- move `source.fictionality` to `work.fictionality` on main entity?
- merge three (?) `work.csv` table