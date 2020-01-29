@test "Eggdrop setup" {
  cd $HOME/eggdrop
  run cp $WORK_DIR/tests/eggdrop_tcl_matchattr* $HOME/eggdrop/
  [ $status -eq 0 ]
  run cp $WORK_DIR/tests/cmd_accept.tcl $HOME/eggdrop/scripts/
  [ $status -eq 0 ]
  run ./eggdrop -m eggdrop_tcl_matchattr.conf
  [ $status -eq 0 ]
  echo "{deluser foo}" |nc localhost 45678
  run bash -c 'echo "{channel add #foober}" |nc localhost 45678'
  [[ ${output} == *"0 {}"* ]]
  run bash -c 'echo "{adduser foo}" |nc localhost 45678'
  echo "HI $output"
  [[ ${output} == *"0 {1}"* ]]
  run bash -c 'echo "{chattr foo +jlmoptx|+lov #foober}" |nc localhost 45678'
  [[ ${output} == *"0 {jlmoptx|lov}"* ]]
}

@test "matchattr with single global + flag returns 1 on user possessing global flag" {
  run bash -c 'echo "{matchattr foo +o}" |nc localhost 45678'
  [[ ${output} == *"0 {1}"* ]]
}

@test "matchattr with single global + flag returns 0 on user not possessing global flag" {
  run bash -c 'echo "{matchattr foo +g}" |nc localhost 45678'
  [[ ${output} == *"0 {0}"* ]]
}

@test "matchattr with 2 + global flags returns 1 on user possessing one of the  global flags" {
  run bash -c 'echo "{matchattr foo +on}" |nc localhost 45678'
  [[ ${output} == *"0 {1}"* ]]
}

@test "matchattr with 2 + global flags returns 0 on user not possessing either global flags" {
  run bash -c 'echo "{matchattr foo +gn}" |nc localhost 45678'
  [[ ${output} == *"0 {0}"* ]]
}

@test "matchattr with 2 + channel flags returns 1 if & specified and user has both global flags" {
  run bash -c 'echo "{matchattr foo +mo& #foober}" |nc localhost 45678'
  [[ ${output} == *"0 {1}"* ]]
}

@test "matchattr with 2 + channels flags returns 0 if & specified and user has one global flag" {
  run bash -c 'echo "{matchattr foo +mn& #foober}" |nc localhost 45678'
  [[ ${output} == *"0 {0}"* ]]
}

@test "matchattr with single global - flag returns 1 on user not possessing global flag" {
  run bash -c 'echo "{matchattr foo -n}" |nc localhost 45678'
  [[ ${output} == *"0 {1}"* ]]
}

@test "matchattr with single global - flag returns 0 on user possessing global flag" {
  run bash -c 'echo "{matchattr foo -m}" |nc localhost 45678'
  [[ ${output} == *"0 {0}"* ]]
}

@test "matchattr with 2 - global flags returns 1 on user not posessing one of the global flags" {
  run bash -c 'echo "{matchattr foo -mn}" |nc localhost 45678'
  [[ ${output} == *"0 {1}"* ]]
}

@test "matchattr with 2 - global flags returns 1 on user not possessing both global flags" {
  run bash -c 'echo "{matchattr foo -gn}" |nc localhost 45678'
  [[ ${output} == *"0 {1}"* ]]
}

@test "matchattr with 2 - global flags returns 0 on user possessing both global flags" {
  run bash -c 'echo "{matchattr foo -om}" |nc localhost 45678'
  [[ ${output} == *"0 {0}"* ]]
}

@test "matchattr with single channel + flag returns 1 on user possessing channel flag" {
  run bash -c 'echo "{matchattr foo |+o #foober}" |nc localhost 45678'
  [[ ${output} == *"0 {1}"* ]]
}

@test "matchattr with single channel + flag returns 0 on user not possessing channel flag" {
  run bash -c 'echo "{matchattr foo |+g #foober}" |nc localhost 45678'
  [[ ${output} == *"0 {0}"* ]]
}

@test "matchattr with 2 + channel flags returns 1 on user possessing one of the channel flags" {
  run bash -c 'echo "{matchattr foo |+on #foober}" |nc localhost 45678'
  [[ ${output} == *"0 {1}"* ]]
}

@test "matchattr with 2 + channel flags returns 0 on user not possessing either channel flag" {
  run bash -c 'echo "{matchattr foo |+gn #foober}" |nc localhost 45678'
  [[ ${output} == *"0 {0}"* ]]
}

@test "matchattr with 2 + channel flags returns 1 if & specified and user has both channel flags" {
  run bash -c 'echo "{matchattr foo &+lo #foober}" |nc localhost 45678'
  [[ ${output} == *"0 {1}"* ]]
}

@test "matchattr with 2 + channels flags returns 0 if & specified and user has one channel flag" {
  run bash -c 'echo "{matchattr foo &+om #foober}" |nc localhost 45678'
  [[ ${output} == *"0 {0}"* ]]
}

@test "matchattr with single channel - flag returns 1 on user not possessing channel flag" {
  run bash -c 'echo "{matchattr foo |-n #foober}" |nc localhost 45678'
  [[ ${output} == *"0 {1}"* ]]
}

@test "matchattr with single channel - flag returns 0 on user possessing channel flag" {
  run bash -c 'echo "{matchattr foo |-o #foober}" |nc localhost 45678'
  [[ ${output} == *"0 {0}"* ]]
}

@test "matchattr with 2 - channel flags returns 1 on user not posessing one of the channel flags" {
  run bash -c 'echo "{matchattr foo |-on #foober}" |nc localhost 45678'
  [[ ${output} == *"0 {1}"* ]]
}

@test "matchattr with 2 - channel flags returns 1 on user not possessing both channel flags" {
  run bash -c 'echo "{matchattr foo |-gn #foober}" |nc localhost 45678'
  [[ ${output} == *"0 {1}"* ]]
}

@test "matchattr with 2 - channel flags returns 0 on user possessing both channel flags" {
  run bash -c 'echo "{matchattr foo |-ov #foober}" |nc localhost 45678'
  [[ ${output} == *"0 {0}"* ]]
}



@test "matchattr rejects invalid global flags" {
  run bash -c 'echo "{matchattr foo +s}" |nc localhost 45678'
  [[ ${output} == *"1 {Unknown flag specified for matching}"* ]]
}

@test "matchattr rejects invalid channel flags" {
  run bash -c 'echo "{matchattr foo |+j #foober}" |nc localhost 45678'
  [[ ${output} == *"1 {Unknown flag specified for matching}"* ]]
}

@test "matchattr rejects invalid bot flags" {
  run bash -c 'echo "{matchattr foo ||+f}" |nc localhost 45678'
  [[ ${output} == *"1 {Unknown flag specified for matching}"* ]]
}

@test "Kill Eggdrop" {
  ps x|grep "[e]ggdrop "
  if [ $? -eq 0 ]; then
    pkill eggdrop
  fi
  if [ -e /home/eggdrop/eggdrop/tempuser.user ]; then
    rm /home/eggdrop/eggdrop/tempsuer.user
  fi
}
