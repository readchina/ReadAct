# Referential Integrity checks for foreign keys in Art related tables
# @see Acts.bats

# ArtWork.csv
@test "check person foreign keys in ArtWork.person_id" {
  result=$(mlr --csv join -j person_id --np --ul -f data/ArtWork.csv then cut -f person_id then uniq -a data/Person.csv | grep -ow -c "P[0-9]+" || true)
  [ "$result" -eq 0 ]
}

@test "check groups foreign keys in ArtWork.person_id" {
  result=$(mlr --csv join -j person_id --np --ul -f data/ArtWork.csv then cut -f person_id then uniq -a data/Institution.csv | grep -ow -c "I[0-9]+" || true)
  [ "$result" -eq 0 ]
}

@test "check art form foreign keys in ArtWork.art_form" {
  run mlr --csv join -j art_form_id --np --ul -f data/ArtWork.csv then cut -f art_form_id then uniq -a -n data/ArtForm.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}
