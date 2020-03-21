# Referential Integrity checks for foreign Act related tables
# The pattern is to resolve the distinct keys via miller (mlr) and count the results
# The count appears in the second line of the output and should always be 0, expect when
# NULL, empty, or unkown are legal values
# For debugging: mlr --csv uniq -c -g agent data/Act.csv

@test "person foreign keys in Act.agent are resolvable" {
  run mlr --csv join -j agent -r person_id --np --ul -f data/Act.csv then cut -f agent then uniq -a -n data/Person.csv
  [ "$status" -eq 0 ]
  # 1 institutional agent is confirmed
  # echo "# count is " ${lines[1]} >&3
  [ "${lines[1]}" -eq 1 ]
}

@test "act type foreign keys in Act.action are resolvable" {
  run mlr --csv join -j action -r action_id --np --ul -f data/Act.csv then cut -f action then uniq -a -n data/ActType.csv
  [ "$status" -eq 0 ]
  # echo "# count is " ${lines[1]} >&3
  [ "${lines[1]}" -eq 0 ]
}

# Since there are multiple types of objects we need to filter for the right kind via grep
# we need to add || true so that null matches don't mess up the test result
@test "primary source foreign keys in Act.act_object are resolvable" {
  result=$(mlr --csv join -j act_object -r prim_source_id --np --ul -f data/Act.csv then cut -f act_object then uniq -a data/PrimarySource.csv | grep -ow -c "PS[0-9]*" || true)
  # echo "# count is " $result >&3
  [ "$result" -eq 2 ]
}

@test "works foreign keys in Act.act_object are resolvable" {
  result=$(mlr --csv join -j act_object -r artwork_id --np --ul -f data/Act.csv then cut -f act_object then uniq -a data/ArtWork.csv | grep -ow -c "AW[0-9]*" || true)
  # echo "# count is " $result >&3
  [ "$result" -eq 0 ]
}

@test "person foreign keys in Act.act_object are resolvable" {
  result=$(mlr --csv join -j act_object -r person_id --np --ul -f data/Act.csv then cut -f act_object then uniq -a data/Person.csv | grep -ow -c "P[0-9]+" || true)
  # echo "# count is " ${lines[1]} >&3
  [ "$result" -eq 0 ]
}

@test "genres foreign keys in Act.act_object are resolvable" {
  result=$(mlr --csv join -j act_object -r genre_id --np --ul -f data/Act.csv then cut -f act_object then uniq -a data/Genre.csv | grep -ow -c "G[0-9]+" || true)
  # echo "# count is " ${lines[1]} >&3
  [ "$result" -eq 0 ]
}

@test "quotes foreign keys in Act.act_object are resolvable" {
  result=$(mlr --csv join -j act_object -r quotation_id --np --ul -f data/Act.csv then cut -f act_object then uniq -a data/Quotation.csv | grep -ow -c "Q[0-9]*" || true)
  # echo "# count is " ${lines[1]} >&3
  [ "$result" -eq 0 ]
}

@test "secondaries source foreign keys in Act.source are resolvable" {
  run mlr --csv join -j source -r sec_source_id --np --ul -f data/Act.csv then cut -f source then uniq -a -n data/SecondarySource.csv
  [ "$status" -eq 0 ]
  # 1 URL accounted for 
  # echo "# count is " ${lines[1]} >&3
  [ "${lines[1]}" -eq 1 ]
}
