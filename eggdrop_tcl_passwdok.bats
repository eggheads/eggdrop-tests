@test "Eggdrop setup" {
  run cp $WORK_DIR/tests/eggdrop_tcl_passwdok* $HOME/eggdrop/
  [ $status -eq 0 ]
  run cp $WORK_DIR/tests/cmd_accept.tcl $HOME/eggdrop/scripts/
  [ $status -eq 0 ]
  run ./eggdrop -m eggdrop_tcl_passwdok.conf
  [ $status -eq 0 ]
  run bash -c 'echo "{adduser foo}" |nc localhost 45678'
}

@test "passwdok returns 1 if the password given matches the password of a user" {
  run bash -c 'echo "{setuser foo PASS asdf}" |nc localhost 45678'
  [[ "${output}" == *"0 {}"* ]]
  run bash -c 'echo "{passwdok foo asdf}" |nc localhost 45678'
  echo "# ${output}" >&3
  [[ "${output}" == *"0 {1}"* ]]
}

@test "passwdok returns 0 if the password given does not match the password of a user" {
  run bash -c 'echo "{setuser foo PASS asdf}" |nc localhost 45678'
  [[ "${output}" == *"0 {}"* ]]
  run bash -c 'echo "{passwdok foo notasdf}" |nc localhost 45678'
  [[ "${output}" == *"0 {0}"* ]]
}

@test "passwdok returns 1 if the password given is "-" and the user has no password" {
  run bash -c 'echo "{setuser foo PASS }" |nc localhost 45678'
  [[ "${output}" == *"0 {}"* ]]
  run bash -c 'echo "{passwdok foo -}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "passwdok returns 0 if the password given is "-" and the user has a password set" {
  run bash -c 'echo "{setuser foo PASS asdf}" |nc localhost 45678'
  [[ "${output}" == *"0 {}"* ]]
  run bash -c 'echo "{passwdok foo -}" |nc localhost 45678'
  [[ "${output}" == *"0 {0}"* ]]
}

@test "passwdok returns 0 if the password given is \"\" and the user has no password set" {
  run bash -c 'echo "{setuser foo PASS}" |nc localhost 45678'
  [[ "${output}" == *"0 {}"* ]]
  run bash -c 'echo "{passwdok foo \"\"}" |nc localhost 45678'
  [[ "${output}" == *"0 {0}"* ]]
}

@test "passwdok returns 0 if the password given is \"\" and the user has a password set" {
  run bash -c 'echo "{setuser foo PASS asdf}" |nc localhost 45678'
  [[ "${output}" == *"0 {}"* ]]
  run bash -c 'echo "{passwdok foo \"\"}" |nc localhost 45678'
  [[ "${output}" == *"0 {0}"* ]]
}

@test "Kill eggdrop" {
  echo "{die}" |nc localhost 45678
}
