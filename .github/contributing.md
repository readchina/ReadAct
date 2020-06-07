# Contributing Guidelines
We welcome contributions to both the contents of the database and as well as our data model. If you are unsure if your data would make a good fit for inclusion into *ReadAct* feel free to open an issue or otherwise get in touch.

We cannot accept PRs that contain personal information, as the result of field work. All data must satisfy the [GDPR](https://gdpr-info.eu).

## Research Assistants (HiWis)
Student assistants who join our project should always consults. the step-by-step guidelines for how to use git, work with spreadsheets, best practices, etc. in the [wiki](https://github.com/readchina/ReadAct/wiki).

## Data Directory
The main data files are in `csv` format and located inside the `csv/data/` directory. The source encoding is `utf-8` and uses **commas** `,` as field separators. The `csv` files are the authoritative files used for populating the SQL database as well as for generating the `tei-xml` files driving the *ReadAct* web application.

## Validation and consistency
To maintain data consistency we use two test suites, which are automatically carried out by our CI service on each commit or PR. Only PRs that satisfy our tests can be reviewed and merged.

Structural changes, e.g. new files or new columns, as opposed to new entries or corrections, require edits to the schema files, the `data-dictionary` located in `data/`, and the bats tests.

### CI and schema files
The [schemas](https://specs.frictionlessdata.io/table-schema/) for validating `csv` can be found in `csv/schema`. The validation is run by  [goodtables-py](https://github.com/frictionlessdata/goodtables-py). To run these locally you need to install `csvlint` according to these [instructions](https://github.com/frictionlessdata/goodtables-py#installing).

Each Schema is named after the corresponding csv table, so e.g. `Act.json` validates `Act.csv`. These are referenced in the `datapackage.json` to validate:
```bash
goodtables validate csv/datapackage.json
```

Alternatively you can take a look at [this webpage](http://csvlint.io)

### Tests
We also run a referential integrity checks via [miller](). These are located inside the `test/` directory. To execute these locally you need to use [bats]().

```bash
bats test/*.bats
```

## Auxiliary Files
We supply two types of auxiliary files:
-   spreadsheets (`LO/*.odf`)
-   networks (`Gephi/*.gexf`)

The spreadsheets are configured to automatically update from the latest csv sources. New diagrams or new network layouts should be added as separate files in the respective parent directories, and be accompanied with a short description in your PR.
