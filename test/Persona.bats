# Referential Integrity checks for foreign keys in Person or Institution related tables
# @see Acts.bats

# Institution
@test "places in Institution.place" {
  run mlr --csv join -j place -r space_id --np --ul -f csv/data/Institution.csv then cut -f place then uniq -a -n csv/data/Space.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

# Membership
@test "groups in Membership.institution" {
  run mlr --csv join -j institution -r inst_id --np --ul -f csv/data/Membership.csv then cut -f institution then uniq -a -n csv/data/Institution.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "individuals in Membership.member" {
  run mlr --csv join -j member -r person_id --np --ul -f csv/data/Membership.csv then cut -f member then uniq -a -n csv/data/Person.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "secondaries in Membership.source" {
  run mlr --csv join -j source -r sec_source_id --np --ul -f csv/data/Act.csv then cut -f source then uniq -a -n csv/data/SecondarySource.csv
  [ "$status" -eq 0 ]
  # URL
  [ "${lines[1]}" -eq 0 ]
}

# Person
@test "places in Person.place_of_rust" {
  run mlr --csv join -j place_of_rust -r space_id --np --ul -f csv/data/Person.csv then cut -f place_of_rust then uniq -a -n csv/data/Space.csv
  [ "$status" -eq 0 ]
  # NULL empty
  [ "${lines[1]}" -eq 2 ]
}

@test "places in Person.place_of_birth" {
  run mlr --csv join -j place_of_birth -r space_id --np --ul -f csv/data/Person.csv then cut -f place_of_birth then uniq -a -n csv/data/Space.csv
  [ "$status" -eq 0 ]
  # NULL empty
  [ "${lines[1]}" -eq 0 ]
}

# @test "places in Person.place_of_death" {
#   run mlr --csv join -j place_of_death -r place_id --np --ul -f csv/data/Person.csv then cut -f place_of_death then uniq -a -n csv/data/Place.csv
#   [ "$status" -eq 0 ]
#   # empty
#   [ "${lines[1]}" -eq 1 ]
# }

@test "status in Person.social_position" {
  run mlr --csv join -j social_position -r soc_pos_id --np --ul -f csv/data/Person.csv then cut -f social_position then uniq -a -n csv/data/SocialPosition.csv
  [ "$status" -eq 0 ]
  # NULL empty unknown
  [ "${lines[1]}" -eq 3 ]
}

# SocialRelation
@test "individuals in SocialRelation.ego" {
  run mlr --csv join -j ego -r person_id --np --ul -f csv/data/SocialRelation.csv then cut -f ego then uniq -a -n csv/data/Person.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "individuals in SocialRelation.person_id" {
  run mlr --csv join -j related -r person_id --np --ul -f csv/data/SocialRelation.csv then cut -f related then uniq -a -n csv/data/Person.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}
