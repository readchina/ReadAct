# Referential Integrity checks for foreign keys in Art related tables
# @see Acts.bats

# ArtWork.csv
@test "individuals in ArtWork.creator" {
  result=$(mlr --csv join -j creator --np --ul -f csv/data/ArtWork.csv then cut -f creator then uniq -a csv/data/Person.csv | grep -ow -c "P[0-9]+" || true)
  [ "$result" -eq 0 ]
}

@test "groups in ArtWork.creator" {
  result=$(mlr --csv join -j creator --np --ul -f csv/data/ArtWork.csv then cut -f creator then uniq -a csv/data/Institution.csv | grep -ow -c "I[0-9]+" || true)
  [ "$result" -eq 0 ]
}

@test "artforms in ArtWork.art_form" {
  run mlr --csv join -j art_form -r art_form_id --np --ul -f csv/data/ArtWork.csv then cut -f art_form then uniq -a -n csv/data/ArtForm.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "places in ArtWork.first_performance_place" {
  run mlr --csv join -j first_performance_place -r space_id --np --ul -f csv/data/ArtWork.csv then cut -f publication_place then uniq -a -n csv/data/Space.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}
