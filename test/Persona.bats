# Referential Integrity checks for foreign keys in Person or Institution related tables
# @see Acts.bats

# Institution
@test "check place foreign keys in Institution.place_id" {
  run mlr --csv join -j place_id -r place_ID --np --ul -f data/Institution.csv then cut -f place_id then uniq -a -n data/Place.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

# Membership
@test "check institution foreign keys in Membership.inst_id" {
  run mlr --csv join -j inst_ID --np --ul -f data/Membership.csv then cut -f inst_ID then uniq -a -n data/Institution.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

@test "check person foreign keys in Membership.person_id" {
  run mlr --csv join -j person_id --np --ul -f data/Membership.csv then cut -f person_id then uniq -a -n data/Person.csv
  [ "$status" -eq 0 ]
  [ "${lines[1]}" -eq 0 ]
}

# Person
@test "check rustication place foreign keys in Person.place_of_rust" {
  run mlr --csv join -j place_of_rust -r place_ID --np --ul -f data/Person.csv then cut -f place_of_rust then uniq -a -n data/Place.csv
  [ "$status" -eq 0 ]
  # NULL empty unknown
  [ "${lines[1]}" -eq 3 ]
}

@test "check birth place foreign keys in Person.place_of_birth" {
  run mlr --csv join -j place_of_birth -r place_ID --np --ul -f data/Person.csv then cut -f place_of_birth then uniq -a -n data/Place.csv
  [ "$status" -eq 0 ]
  # NULL empty unknown
  [ "${lines[1]}" -eq 3 ]
}

@test "check death place foreign keys in Person.place_of_death" {
  run mlr --csv join -j place_of_death -r place_ID --np --ul -f data/Person.csv then cut -f place_of_death then uniq -a -n data/Place.csv
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
