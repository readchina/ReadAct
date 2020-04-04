# Referential Integrity checks for foreign Act related tables
# The pattern is to resolve the distinct keys via miller (mlr) and count the results
# The count appears in the second line of the output and should always be 0, expect when
# NULL, empty, or unkown are legal values
# For debugging: mlr --csv uniq -c -g agent csv/data/Act.csv

@test "individuals in Act.agent" {
  run mlr --csv join -j agent -r person_id --np --ul -f csv/data/Act.csv then cut -f agent then uniq -a -n csv/data/Person.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "types in Act.action" {
  run mlr --csv join -j action -r action_id --np --ul -f csv/data/Act.csv then cut -f action then uniq -a -n csv/data/ActType.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

# Since there are multiple types of objects we need to filter for the right kind via grep
# we need to add || true so that null matches don't mess up the test result
@test "works in Act.act_object" {
  result=$(mlr --csv join -j act_object -r work_id --np --ul -f csv/data/Act.csv then cut -f act_object then uniq -a csv/data/Work.csv | grep -ow -c "W[0-9]*" || true)
  [ "$result" -eq 0 ]
}

@test "individuals in Act.act_target" {
  result=$(mlr --csv join -j act_target -r person_id --np --ul -f csv/data/Act.csv then cut -f act_object then uniq -a csv/data/Person.csv | grep -ow -c "P[0-9]+" || true)
  [ "$result" -eq 0 ]
}

@test "genres in Act.act_object" {
  result=$(mlr --csv join -j act_object -r genre_id --np --ul -f csv/data/Act.csv then cut -f act_object then uniq -a csv/data/Genre.csv | grep -ow -c "G[0-9]+" || true)
  [ "$result" -eq 0 ]
}

@test "quotes in Act.act_object" {
  result=$(mlr --csv join -j act_object -r quotation_id --np --ul -f csv/data/Act.csv then cut -f act_object then uniq -a csv/data/Quotation.csv | grep -ow -c "Q[0-9]*" || true)
  [ "$result" -eq 0 ]
}

@test "secondaries in Act.source" {
  run mlr --csv join -j source -r sec_source_id --np --ul -f csv/data/Act.csv then cut -f source then uniq -a -n csv/data/SecondarySource.csv
  [ "$status" -eq 0 ]
  # URL
  [ "${lines[1]}" -eq 1 ]
}
