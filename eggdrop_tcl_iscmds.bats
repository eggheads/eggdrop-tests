iscmd00() {
  echo "{$2 *!test@foo.com $4 $5}" |nc localhost 45678
  echo "{$3 #foober *!test@foo.com}" |nc localhost 45678
  run bash -c 'echo "{$1 *!test@foo.com}" |nc localhost 45678'
}

@test "Eggdrop setup" {
  run cp /tmp/build/tests/eggdrop_tcl_iscmds* $HOME/eggdrop/
  [ $status -eq 0 ]
  run cp /tmp/build/tests/cmd_accept.tcl $HOME/eggdrop/scripts/
  [ $status -eq 0 ]
  run ./eggdrop -m eggdrop_tcl_iscmds.conf
  [ $status -eq 0 ]
  run bash -c 'echo "{channel add #foober}" |nc localhost 45678'
}

###############
### Check isban
###############

@test "isban returns 0 if global and channel bans DNE" {
  echo "{killban *!test@foo.com}" |nc localhost 45678
  echo "{killchanban #foober *!test@foo.com}" |nc localhost 45678
  run bash -c 'echo "{isban *!test@foo.com}" |nc localhost 45678'
  [[ "${output}" == *"0 {0}"* ]]
}

@test "isban returns 1 if only global ban is present" {
  echo "{newban *!test@foo.com testuser comment}" |nc localhost 45678
  echo "{killchanban #foober *!test@foo.com}" |nc localhost 45678
  run bash -c 'echo "{isban *!test@foo.com}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isban #channel returns 1 if only channel ban is present" {
  echo "{killban *!test@foo.com}" |nc localhost 45678
  echo "{newchanban #foober *!test@foo.com testuser comment}" |nc localhost 45678
  run bash -c 'echo "{isban *!test@foo.com #foober}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isban returns 1 if global and channel ban is present" {
  echo "{newban #foober *!test@foo.com testuser comment}" |nc localhost 45678
  echo "{newchanban #foober *!test@foo.com testuser comment}" |nc localhost 45678
  run bash -c 'echo "{isban *!test@foo.com #foober}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isban #channel returns 1 if global and channel ban is present" {
  echo "{newchanban #foober *!test@foo.com testuser comment}" |nc localhost 45678
  echo "{newban *!test@foo.com testuser comment}" |nc localhost 45678
  run bash -c 'echo "{isban *!test@foo.com}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isban #channel returns 0 if only global ban is present" {
  echo "{killchanban #foober *!test@foo.com}" |nc localhost 45678
  echo "{newban *!test@foo.com testuser comment}" |nc localhost 45678
  run bash -c 'echo "{isban *!test@foo.com #foober}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isban returns 0 if only channel ban is present" {
  echo "{killban *!test@foo.com}" |nc localhost 45678
  echo "{newchanban #foober *!test@foo.com testuser comment}" |nc localhost 45678
  run bash -c 'echo "{isban *!test@foo.com}" |nc localhost 45678'
  [[ "${output}" == *"0 {0}"* ]]
}

#####################
### Check sticky bans
#####################

@test "isbansticky returns 0 if global and channel bans DNE" {
  echo "{killchanban #foober *!test@foo.com}" |nc localhost 45678
  echo "{killban *!test@foo.com}" |nc localhost 45678
  run bash -c 'echo "{isbansticky *!test@foo.com}" |nc localhost 45678'
  [[ "${output}" == *"0 {0}"* ]]
}

@test "isbansticky returns 1 if only global ban is present" {
  echo "{killchanban #foober *!test@foo.com}" |nc localhost 45678
  echo "{newban *!test@foo.com testuser comment 60 sticky}" |nc localhost 45678
  run bash -c 'echo "{isbansticky *!test@foo.com}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isbansticky #channel returns 1 if only channel ban is present" {
  echo "{killban *!test@foo.com}" |nc localhost 45678
  echo "{newchanban #foober *!test@foo.com testuser commenti 60 sticky}" |nc localhost 45678
  run bash -c 'echo "{isbansticky *!test@foo.com #foober}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isbansticky returns 1 if global and channel ban is present" {
  echo "{newban #foober *!test@foo.com testuser comment 60 sticky}" |nc localhost 45678
  echo "{newchanban #foober *!test@foo.com testuser comment 60 sticky}" |nc localhost 45678
  run bash -c 'echo "{isbansticky *!test@foo.com #foober}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isbansticky #channel returns 1 if global and channel ban is present" {
  echo "{newchanban #foober *!test@foo.com testuser comment 60 sticky}" |nc localhost 45678
  echo "{newban *!test@foo.com testuser comment 60 sticky}" |nc localhost 45678
  run bash -c 'echo "{isbansticky *!test@foo.com}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isbansticky #channel returns 0 if only global ban is present" {
  echo "{killchanban #foober *!test@foo.com}" |nc localhost 45678
  echo "{newban *!test@foo.com testuser comment 60 sticky}" |nc localhost 45678
  run bash -c 'echo "{isbansticky *!test@foo.com #foober}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isbansticky returns 0 if only channel ban is present" {
  echo "{killban *!test@foo.com}" |nc localhost 45678
  echo "{newchanban #foober *!test@foo.com testuser comment 60 sticky}" |nc localhost 45678
  run bash -c 'echo "{isban *!test@foo.com}" |nc localhost 45678'
  [[ "${output}" == *"0 {0}"* ]]
}


##################
### Check isexempt
##################

@test "isexempt returns 0 if global and channel exempts DNE" {
  echo "{killchanexempt #foober *!test@foo.com}" |nc localhost 45678
  echo "{killexempt *!test@foo.com}" |nc localhost 45678
  run bash -c 'echo "{isexempt *!test@foo.com}" |nc localhost 45678'
  [[ "${output}" == *"0 {0}"* ]]
}

@test "isexempt returns 1 if only global exempt is present" {
  echo "{killchanexempt #foober *!test@foo.com}" |nc localhost 45678
  echo "{newexempt *!test@foo.com testuser comment}" |nc localhost 45678
  run bash -c 'echo "{isexempt *!test@foo.com}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isexempt channel returns 1 if only channel exempt is present" {
  echo "{killexempt *!test@foo.com}" |nc localhost 45678
  echo "{newchanexempt #foober *!test@foo.com testuser comment}" |nc localhost 45678
  run bash -c 'echo "{isexempt *!test@foo.com #foober}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isexempt returns 1 if global and channel exempt is present" {
  echo "{newexempt #foober *!test@foo.com testuser comment}" |nc localhost 45678
  echo "{newchanexempt #foober *!test@foo.com testuser comment}" |nc localhost 45678
  run bash -c 'echo "{isexempt *!test@foo.com #foober}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isexempt #channel returns 1 if global and channel exempt is present" {
  echo "{newchanexempt #foober *!test@foo.com testuser comment}" |nc localhost 45678
  echo "{newexempt *!test@foo.com testuser comment}" |nc localhost 45678
  run bash -c 'echo "{isexempt *!test@foo.com}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isexempt #channel returns 0 if only global exempt is present" {
  echo "{killchanexempt #foober *!test@foo.com}" |nc localhost 45678
  echo "{newexempt *!test@foo.com testuser comment}" |nc localhost 45678
  run bash -c 'echo "{isexempt *!test@foo.com #foober}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isexempt returns 0 if only channel exempt is present" {
  echo "{killexempt *!test@foo.com}" |nc localhost 45678
  echo "{newchanexempt foober *!test@foo.com testuser comment}" |nc localhost 45678
  run bash -c 'echo "{isexempt *!test@foo.com}" |nc localhost 45678'
  [[ "${output}" == *"0 {0}"* ]]
}

##################
### Check isinvite
##################

@test "isinvite returns 0 if global and channel invites DNE" {
  echo "{killchaninvite #foober *!test@foo.com}" |nc localhost 45678
  echo "{killinvite *!test@foo.com}" |nc localhost 45678
  run bash -c 'echo "{isinvite *!test@foo.com}" |nc localhost 45678'
  [[ "${output}" == *"0 {0}"* ]]
}

@test "isinvite returns 1 if only global invite is present" {
  echo "{killchaninvite #foober *!test@foo.com}" |nc localhost 45678
  echo "{newinvite *!test@foo.com testuser comment}" |nc localhost 45678
  run bash -c 'echo "{isinvite *!test@foo.com}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isinvite #channel returns 1 if only channel invite is present" {
  echo "{killinvite *!test@foo.com}" |nc localhost 45678
  echo "{newchaninvite #foober *!test@foo.com testuser comment}" |nc localhost 45678
  run bash -c 'echo "{isinvite *!test@foo.com #foober}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isinvite returns 1 if global and channel invite is present" {
  echo "{newinvite #foober *!test@foo.com testuser comment}" |nc localhost 45678
  echo "{newchaninvite #foober *!test@foo.com testuser comment}" |nc localhost 45678
  run bash -c 'echo "{isinvite *!test@foo.com #foober}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isinvite #channel returns 1 if global and channel invite is present" {
  echo "{newchaninvite #foober *!test@foo.com testuser comment}" |nc localhost 45678
  echo "{newinvite *!test@foo.com testuser comment}" |nc localhost 45678
  run bash -c 'echo "{isinvite *!test@foo.com}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isinvite #channel returns 0 if only global invite is present" {
  echo "{killchaninvite #foober *!test@foo.com}" |nc localhost 45678
  echo "{newinvite *!test@foo.com testuser comment}" |nc localhost 45678
  run bash -c 'echo "{isinvite *!test@foo.com #foober}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
}

@test "isinvite returns 0 if only channel invite is present" {
  echo "{killinvite *!test@foo.com}" |nc localhost 45678
  echo "{newchaninvite #foober *!test@foo.com testuser comment}" |nc localhost 45678
  run bash -c 'echo "{isinvite *!test@foo.com}" |nc localhost 45678'
  [[ "${output}" == *"0 {0}"* ]]
}



@test "Eggdrop dies" {
  run bash -c 'reply=$(echo {die} |nc localhost 45678); echo $reply | cut -d "{" -f2 | cut -d "}" -f1'
  [ $status -eq 0 ]
}



