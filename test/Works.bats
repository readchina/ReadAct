# Referential Integrity checks for foreign keys in Text related tables
# @see Acts.bats

# Work
@test "Works: agents in Work.creator" {
  run mlr --csv join -j creator -r agent_id --np --ul -f csv/data/Work.csv then cut -f creator then uniq -a -n csv/data/Agent.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "Works: language in Work.language" {
  run mlr --csv join -j language -r iso_code --np --ul -f csv/data/Work.csv then cut -f language then uniq -a -n csv/data/IsoLangCode.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

# PrimarySource
@test "Works: genres in PrimarySource.genre" {
  run mlr --csv join -j genre -r genre_id --np --ul -f csv/data/PrimarySource.csv then cut -f genre then uniq -a -n csv/data/Genre.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "Works: language in PrimarySource.title_lang" {
  run mlr --csv join -j title_lang -r iso_code --np --ul -f csv/data/PrimarySource.csv then cut -f title_lang then uniq -a -n csv/data/IsoLangCode.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "Works: places in PrimarySource.publication_place" {
  run mlr --csv join -j publication_place -r space_id --np --ul -f csv/data/PrimarySource.csv then cut -f publication_place then uniq -a -n csv/data/Space.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

# SecondarySource
@test "Works: genre in SecondarySource.genre" {
  run mlr --csv join -j genre -r genre_id --np --ul -f csv/data/SecondarySource.csv then cut -f genre then uniq -a -n csv/data/Genre.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "Works: language in SecondarySource.title_lang" {
  run mlr --csv join -j title_lang -r iso_code --np --ul -f csv/data/SecondarySource.csv then cut -f title_lang then uniq -a -n csv/data/IsoLangCode.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "Works: places in SecondarySource.publication_place" {
  run mlr --csv join -j publication_place -r space_id --np --ul -f csv/data/SecondarySource.csv then cut -f publication_place then uniq -a -n csv/data/Space.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

# Quotation
@test "Works: primaries in Quotation.source" {
  result=$(mlr --csv join -j source --np --ul -f csv/data/Quotation.csv then cut -f source then uniq -a csv/data/Work.csv | grep -ow -c "W[0-9]+" || true)
  [ "$result" -eq 0 ]
}

@test "Works: secondaries in Quotation.source_id" {
  result=$(mlr --csv join -j source --np --ul -f csv/data/Quotation.csv then cut -f source then uniq -a csv/data/Work.csv | grep -ow -c "W[0-9]+" || true)
  [ "$result" -eq 0 ]
}

# ArtWork.csv
@test "Works: artforms in ArtWork.art_form" {
  run mlr --csv join -j art_form -r art_form_id --np --ul -f csv/data/ArtWork.csv then cut -f art_form then uniq -a -n csv/data/ArtForm.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "Works: language in ArtWork.title_lang" {
  run mlr --csv join -j title_lang -r iso_code --np --ul -f csv/data/ArtWork.csv then cut -f title_lang then uniq -a -n csv/data/IsoLangCode.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "Works: places in ArtWork.first_performance_place" {
  run mlr --csv join -j first_performance_place -r space_id --np --ul -f csv/data/ArtWork.csv then cut -f publication_place then uniq -a -n csv/data/Space.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

# Genre
@test "Works: language in Genre.genre_name_lang" {
  run mlr --csv join -j genre_name_lang -r iso_code --np --ul -f csv/data/Genre.csv then cut -f genre_name_lang then uniq -a -n csv/data/IsoLangCode.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

# ArtForm
@test "Works: language in ArtForm.art_form_name_lang" {
  run mlr --csv join -j art_form_name_lang -r iso_code --np --ul -f csv/data/ArtForm.csv then cut -f art_form_name_lang then uniq -a -n csv/data/IsoLangCode.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}
