# Referential Integrity checks for foreign keys in Person or Institution related tables
# @see Acts.bats

# Institution
@test "check place foreign keys in Institution.place" {
  run mlr --csv join -j place -r place_id --np --ul -f data/Institution.csv then cut -f place then uniq -a -n data/Place.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

# Membership
@test "check institution foreign keys in Membership.institution" {
  run mlr --csv join -j institution -r inst_id --np --ul -f data/Membership.csv then cut -f institution then uniq -a -n data/Institution.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "check person foreign keys in Membership.member" {
  run mlr --csv join -j member -r person_id --np --ul -f data/Membership.csv then cut -f member then uniq -a -n data/Person.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "check source foreign keys in Membership.source" {
  run mlr --csv join -j source -r sec_source_id --np --ul -f data/Act.csv then cut -f source then uniq -a -n data/SecondarySource.csv
  [ "$status" -eq 0 ]
  # URL
  [ "${lines[1]}" -eq 1 ]
}

# Person
@test "check rustication place foreign keys in Person.place_of_rust" {
  run mlr --csv join -j place_of_rust -r place_id --np --ul -f data/Person.csv then cut -f place_of_rust then uniq -a -n data/Place.csv
  [ "$status" -eq 0 ]
  # NULL empty
  [ "${lines[1]}" -eq 2 ]
}

@test "check birth place foreign keys in Person.place_of_birth" {
  run mlr --csv join -j place_of_birth -r place_id --np --ul -f data/Person.csv then cut -f place_of_birth then uniq -a -n data/Place.csv
  [ "$status" -eq 0 ]
  # NULL empty
  [ "${lines[1]}" -eq 2 ]
}

@test "check death place foreign keys in Person.place_of_death" {
  run mlr --csv join -j place_of_death -r place_id --np --ul -f data/Person.csv then cut -f place_of_death then uniq -a -n data/Place.csv
  [ "$status" -eq 0 ]
  # empty
  [ "${lines[1]}" -eq 1 ]
}

@test "check social position foreign keys in Person.social_position" {
  run mlr --csv join -j social_position -r soc_pos_id --np --ul -f data/Person.csv then cut -f social_position then uniq -a -n data/SocialPosition.csv
  [ "$status" -eq 0 ]
  # NULL empty unknown
  [ "${lines[1]}" -eq 3 ]
}

# SocialRelation
@test "check ego foreign keys in SocialRelation.person_id" {
  run mlr --csv join -j ego -r person_id --np --ul -f data/SocialRelation.csv then cut -f ego then uniq -a -n data/Person.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "check related foreign keys in SocialRelation.person_id" {
  run mlr --csv join -j related -r person_id --np --ul -f data/SocialRelation.csv then cut -f related then uniq -a -n data/Person.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}
