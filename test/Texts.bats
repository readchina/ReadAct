# Referential Integrity checks for foreign keys in Text related tables
# @see Acts.bats

# PrimarySource
@test "individuals in PrimarySource.author" {
  result=$(mlr --csv join -j author --np --ul -f csv/data/PrimarySource.csv then cut -f author then uniq -a csv/data/Person.csv | grep -ow -c "P[0-9]+" || true)
  [ "$result" -eq 0 ]
}

@test "groups in PrimarySource.author" {
  result=$(mlr --csv join -j author --np --ul -f csv/data/PrimarySource.csv then cut -f author then uniq -a csv/data/Institution.csv | grep -ow -c "I[0-9]+" || true)
  [ "$result" -eq 0 ]
}

@test "genres in PrimarySource.genre" {
  run mlr --csv join -j genre -r genre_id --np --ul -f csv/data/PrimarySource.csv then cut -f genre then uniq -a -n csv/data/Genre.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "places in PrimarySource.publication_place" {
  run mlr --csv join -j publication_place -r space_id --np --ul -f csv/data/PrimarySource.csv then cut -f publication_place then uniq -a -n csv/data/Space.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

# SecondarySource
@test "individuals in SecondarySource.author" {
  result=$(mlr --csv join -j author --np --ul -f csv/data/SecondarySource.csv then cut -f author then uniq -a csv/data/Person.csv | grep -ow -c "P[0-9]+" || true)
  [ "$result" -eq 0 ]
}

@test "groups in SecondarySource.author" {
  result=$(mlr --csv join -j author --np --ul -f csv/data/SecondarySource.csv then cut -f author then uniq -a csv/data/Institution.csv | grep -ow -c "I[0-9]+" || true)
  [ "$result" -eq 0 ]
}

@test "genre in SecondarySource.genre" {
  run mlr --csv join -j genre -r genre_id --np --ul -f csv/data/SecondarySource.csv then cut -f genre then uniq -a -n csv/data/Genre.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "places in SecondarySource.publication_place" {
  run mlr --csv join -j publication_place -r space_id --np --ul -f csv/data/SecondarySource.csv then cut -f publication_place then uniq -a -n csv/data/Space.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

# Quotation
@test "primaries in Quotation.source" {
  result=$(mlr --csv join -j source --np --ul -f csv/data/Quotation.csv then cut -f source then uniq -a csv/data/Work.csv | grep -ow -c "W[0-9]+" || true)
  [ "$result" -eq 0 ]
}

@test "secondaries in Quotation.source_id" {
  result=$(mlr --csv join -j source --np --ul -f csv/data/Quotation.csv then cut -f source then uniq -a csv/data/Work.csv | grep -ow -c "W[0-9]+" || true)
  [ "$result" -eq 0 ]
}
