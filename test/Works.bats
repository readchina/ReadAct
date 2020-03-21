# Referential Integrity checks for foreign keys in Art related tables
# @see Acts.bats

# ArtWork.csv
@test "person foreign keys in ArtWork.creator are resolvable" {
  result=$(mlr --csv join -j creator --np --ul -f data/ArtWork.csv then cut -f creator then uniq -a data/Person.csv | grep -ow -c "P[0-9]+" || true)
  [ "$result" -eq 0 ]
}

@test "group foreign keys in ArtWork.creator are resolvables" {
  result=$(mlr --csv join -j creator --np --ul -f data/ArtWork.csv then cut -f creator then uniq -a data/Institution.csv | grep -ow -c "I[0-9]+" || true)
  [ "$result" -eq 0 ]
}

@test "artform foreign keys in ArtWork.art_form are resolvable" {
  run mlr --csv join -j art_form -r art_form_id --np --ul -f data/ArtWork.csv then cut -f art_form then uniq -a -n data/ArtForm.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}
