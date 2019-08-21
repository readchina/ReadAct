# Referential Integrity checks for foreign Act related tables
# The pattern is to resolve the distinct keys via miller (mlr) and count the results
# The count appears in the second line of the output and should always be 0, expect when
# NULL, empty, or unkown are legal values
# For debugging: mlr --csv uniq -c -g agent data/Act.csv

@test "check person foreign keys in Act.agent" {
  run mlr --csv join -j agent -r person_id --np --ul -f data/Act.csv then cut -f agent then uniq -a -n data/Person.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "check act type foreign keys in Act.action" {
  run mlr --csv join -j action -r action_ID --np --ul -f data/Act.csv then cut -f action then uniq -a -n data/ActType.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

# Since there are multiple types of objects we need to filter for the right kind via grep
# we need to add || true so that null matches don't mess up the test result
@test "check primary source foreign keys in Act.act_object" {
  result=$(mlr --csv join -j act_object -r prim_source_id --np --ul -f data/Act.csv then cut -f act_object then uniq -a data/PrimarySource.csv | grep -ow -c "PS[0-9]*" || true)
  [ "$result" -eq 3 ]
}

@test "check art work foreign keys in Act.act_object" {
  result=$(mlr --csv join -j act_object -r artwork_id --np --ul -f data/Act.csv then cut -f act_object then uniq -a data/ArtWork.csv | grep -ow -c "AW[0-9]*" || true)
  [ "$result" -eq 1 ]
}

@test "check person foreign keys in Act.act_object" {
  result=$(mlr --csv join -j act_object -r person_id --np --ul -f data/Act.csv then cut -f act_object then uniq -a data/Person.csv | grep -ow -c "P[0-9]+" || true)
  [ "$result" -eq 0 ]
}

@test "check genre foreign keys in Act.act_object" {
  result=$(mlr --csv join -j act_object -r genre_id --np --ul -f data/Act.csv then cut -f act_object then uniq -a data/Genre.csv | grep -ow -c "G[0-9]+" || true)
  [ "$result" -eq 0 ]
}

@test "check quote foreign keys in Act.act_object" {
  result=$(mlr --csv join -j act_object -r quotation_id --np --ul -f data/Act.csv then cut -f act_object then uniq -a data/Quotation.csv | grep -ow -c "Q[0-9]*" || true)
  [ "$result" -eq 0 ]
}

@test "check secondary source foreign keys in Act.source_id" {
  run mlr --csv join -j source_id -r sec_source_id --np --ul -f data/Act.csv then cut -f source_id then uniq -a -n data/SecondarySource.csv
  [ "$status" -eq 0 ]
  # URL
  [ "${lines[1]}" -eq 1 ]
}
