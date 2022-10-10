# ReadAct

[![CI](https://github.com/readchina/ReadAct/actions/workflows/ci.yml/badge.svg)](https://github.com/readchina/ReadAct/actions/workflows/ci.yml) [![DOI](https://zenodo.org/badge/96089230.svg)](https://zenodo.org/badge/latestdoi/96089230)

This repository contains the main data files for the *ReadAct* database. *ReadAct* collects data about reading habits during China's long 1970s: Who read what when with whom why under what circumstances for what purposes? What impact did this have on individuals and on Chinese society? For version `1.x` our  sources are autobiographical texts in Chinese and other languages. As of version `2.x` we added reading acts of as they occur in fictional sources. For more information, please consult our [documentation](https://readchina.github.io/readact.html).

[ReadActor](https://github.com/readchina/ReadActor) is an accompanying tool for automating [wikidata](https://www.wikidata.org/) lookups and data retrieval. We encourage anybody working with ReadAct to familiarize themselves with its capabilities.

## Use

The canonical data is located in `csv/data/*.csv`. It captures reading acts on the main table `Act.csv` with relational tables branching of it. These are the files to work with when developing ReadActor. You can query the data programmatically within you language and application of choice. 

For convenience we also provide a copy of the data as `tei-xml` inside `xml/*.xml` the `tei-header.xml` specifies `xincludes` that create a full TEI representation of the dataset. These files are automatically generated, you can regenerate them locally by running the transformations inside `xml/modules/` with your preferred xquery processor. 

Both xml and csv are continuously updated and validated on CI. 

## Requirements

To use the data any xml or csv capable text-editor will do. 

## Requirements for local development

-  Python: `>=3.8`
- [frictionless-py](https://github.com/frictionlessdata/frictionless-py)
- [ReadActor](https://github.com/readchina/ReadActor) (*helper module*)
- [daff](https://github.com/paulfitz/daff)(*for better csv diffing*)
- [basex](https://basex.org) (*testing only*)
- [textql](https://github.com/dinedal/textql) (*testing only*)

Provided you have python installed, run:

`pip install ReadActor pandas frictionless csvkit daff`


## New contributors

New contributors should consult these [guidelines](.github/contributing.md)
Please check the [wiki](https://github.com/readchina/ReadAct/wiki) for general how-to's, FAQ, and to learn about best practices.
