# Referential Integrity checks for foreign Act related tables
# The pattern is to resolve the distinct keys via miller (mlr) and count the results
# The count appears in the second line of the output and should always be 0, expect when
# NULL, empty, or unkown are legal values
# For debugging: mlr --csv uniq -c -g agent csv/data/Act.csv
# To see the offending values run the test command without the final -n flag

@test "Acts: individuals in Act.agent" {
  run mlr --csv join -j agent -r person_id --np --ul -f csv/data/Act.csv then cut -f agent then uniq -a -n csv/data/Person.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "Acts: types in Act.action" {
  run mlr --csv join -j action -r action_id --np --ul -f csv/data/Act.csv then cut -f action then uniq -a -n csv/data/ActType.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "Acts: works in Act.act_object" {
  run mlr --csv join -j act_object -r work_id --np --ul -f csv/data/Act.csv then cut -f action then uniq -a -n csv/data/Work.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "Acts: agents in Act.target" {
  run mlr --csv join -j act_target -r agent_id --np --ul -f csv/data/Act.csv then cut -f act_target then uniq -a -n csv/data/Agent.csv
  [ "$status" -eq 0 ]
  # empty
  [ "${lines[1]}" -eq 1 ]
}

@test "Acts: secondaries in Act.source" {
  run mlr --csv join -j source -r sec_source_id --np --ul -f csv/data/Act.csv then cut -f source then uniq -a -n csv/data/SecondarySource.csv
  [ "$status" -eq 0 ]
  # URL
  [ "${lines[1]}" -eq 0 ]
}

@test "Acts: language in Act.id_lang" {
  run mlr --csv join -j id_lang -r iso_code --np --ul -f csv/data/Act.csv then cut -f id_lang then uniq -a -n csv/data/IsoLangCode.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

# If there are multiple types of objects we need to filter for the right kind via grep
# we need to add || true so that null matches don't mess up the test result, e.g. this test for Works and another for Quotes,...:
# @test "Acts: works in Act.act_object_old" {
#   result=$(mlr --csv join -j act_object -r work_id --np --ul -f csv/data/Act.csv then cut -f act_object then uniq -a csv/data/Work.csv | grep -ow -c "W[0-9]*" || true)
#   [ "$result" -eq 0 ]
# }
