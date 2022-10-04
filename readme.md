# ReadAct

[![CI](https://github.com/readchina/ReadAct/actions/workflows/ci.yml/badge.svg)](https://github.com/readchina/ReadAct/actions/workflows/ci.yml) [![DOI](https://zenodo.org/badge/96089230.svg)](https://zenodo.org/badge/latestdoi/96089230)

This repository contains the main data files for the *ReadAct* database. *ReadAct* collects data about reading habits during China's long 1970s: Who read what when with whom why under what circumstances for what purposes? What impact did this have on individuals and on Chinese society? Our main sources are autobiographical texts in Chinese and other languages. For more information, please consult our [documentation](https://readchina.github.io/readact.html).

As of version 2.0.0 we us [ReadActor](https://github.com/readchina/ReadActor) for [wikidata](https://www.wikidata.org/) lookups and data retrieval. This tool will run automatically within the CI of ReadAct. However, you can also run this tool locally.

## Requirements for local development

- [frictionless-py](https://github.com/frictionlessdata/frictionless-py)
- [basex](https://basex.org) (*testing only*)
- [textql](https://github.com/dinedal/textql) (*testing only*)
- [ReadActor](https://github.com/readchina/ReadActor) (*helper module*)

## New contributors

New contributors should consult these [guidelines](.github/contributing.md)
Please check the [wiki](https://github.com/readchina/ReadAct/wiki) for general how-to's, FAQ, and to learn about best practices.
