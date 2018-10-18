# READING DATA
[![Build Status](https://travis-ci.com/readchina/ReadingData.svg?branch=master)](https://travis-ci.com/readchina/ReadingData)


In the repository, we collect data about reading habits during China's long 1970s: Who read what when with whom why under what circumstances for what purposes? What impact did this have on individuals and on Chinese society? Our main sources are autobiographical texts in Chinese and other languages. For more information, please consult our project [homepage](http://www.sinologie.uni-freiburg.de/forschung/projecthenningsen).

#### New contributors
Please check the [wiki](https://github.com/readchina/ReadingData/wiki) for general how-to's, FAQ, and to learn about best practices.

#### Validation
The schema's for validating our CSV files can be found at [readchina/csv-schema](https://github.com/readchina/csv-schema). The validation is run by  [csvlint](https://github.com/theodi/csvlint.rb) and are automatically carried out by our CI service on each commit or PR.

To run them locally you need to csvlint on your computer by following [these  instructions](https://github.com/theodi/csvlint.rb#installation). Each Schema is named after the corresponding csv table, so e.g. `Act.json` validates `Act.csv`. Simply navigate to the `ReadingData` folder on your hard-drive and run this command in your CLI of choice:
```bash
csvlint data/Act.csv --schema=https://raw.githubusercontent.com/readchina/csv-schema/master/readingdata/Act.json
```

Alternatively you can take a look at [this webpage](http://csvlint.io)
