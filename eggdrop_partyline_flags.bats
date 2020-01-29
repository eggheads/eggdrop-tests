USERFLAGS="a a c d e f g h j k l m n o p q r t u v w x y z"
# b skipped because a user can't set it
NONUSERFLAGS="b b i s"
BOTFLAGS="a a h i l p r s" 
NONBOTFLAGS="b b c d e f j k m n o q t u v w x y z"
CHANFLAGS="a a d e f g k l m n o q r v w y z"
NONCHANFLAGS="b b c h i j p s t u w"
NBCFLAGS="a a b c d e f g h i j k l m n o p q r t u v w x y z"

@test "Eggdrop setup" {
  run cp $WORK_DIR/tests/eggdrop_partyline_flags* $HOME/eggdrop/
  [ $status -eq 0 ]
  run cp $WORK_DIR/tests/cmd_accept.tcl $HOME/eggdrop/scripts/
  [ $status -eq 0 ]
  run ./eggdrop eggdrop_partyline_flags.conf
  [ $status -eq 0 ]
  echo "{channel add #foober}" |nc localhost 45678
  echo "{adduser uuu}" |nc localhost 45678
  echo "{addbot bbb 1.2.3.4}" |nc localhost 45678
}

@test "Eggdrop sets all allowed global user flags for a user" {
skip
  run bash -c '( FOO=$@; echo "testuser1"; echo "$PASS"; sleep 3; for i in ${FOO}; do echo ".chattr uuu -abcdefghjklmnopqrtuvwxyz"; echo ".chattr uuu +${i}"; sleep 1; echo ".whois uuu"; sleep 1; done; sleep 1; echo ".quit"; ) |telnet localhost 1111' $USERFLAGS
  for j in ${USERFLAGS}; do
    BAR="chattr uuu \+($j)\sGlobal flags for \S+ are now \+\S*\1\S*\."
    [[ ${output} =~ ${BAR} ]]
  done
}

@test "Eggdrop rejects all non-allowed global user flags for a user" {
skip
  run bash -c '( FOO=$@; echo "testuser1"; echo "$PASS"; sleep 3; for i in ${FOO}; do echo ".chattr uuu -abcdefghjklmnopqrtuvwxyz"; echo ".chattr uuu +${i}"; sleep 1; echo ".whois uuu"; sleep 1; done; sleep 1; echo ".quit"; ) |telnet localhost 1111' $NONUSERFLAGS
  for j in ${NONUSERFLAGS}; do
    BAR="chattr uuu \+($j)\sGlobal flags for \S+ are now \+\S*\1\S*\."
    [[ ! ${output} =~ ${BAR} ]]
  done
}

@test "Eggdrop sets all allowed global bot flags for a bot" {
  run bash -c '( FOO=$@; echo "testuser1"; echo "$PASS"; sleep 3; for i in ${FOO}; do echo ".botattr bbb -abcdefghijklmnopqrstuvwxyz"; echo ".botattr bbb +${i}"; sleep 1; echo ".whois bbb"; sleep 1; done; sleep 1; echo ".quit"; ) |telnet localhost 1111' $BOTFLAGS
  for j in ${BOTFLAGS}; do
    BAR="botattr bbb \+($j)\sBot flags for \S+ are now \+\S*\1\S*\."
    echo "Flag is: $j"
    [[ ${output} =~ $BAR ]]
  done
}

@test "Eggdrop rejects all non-allowed global bot flags for a bot" {
  run bash -c '( FOO=$@; sleep 3; echo "testuser1"; echo "$PASS"; for i in ${FOO}; do echo ".botattr bbb -abcdefghijklmnopqrstuvwxyz"; echo ".botattr bbb +${i}"; sleep 1; echo ".whois bbb"; sleep 1; done; sleep 1; echo ".quit"; ) |telnet localhost 1111' $NONBOTFLAGS
  for j in ${NONBOTFLAGS}; do
    BAR="botattr bbb \+($j)\sBot flags for \S+ are now \+\S*\1\S*\."
    echo "Flag is: $j"
    [[ ! ${output} =~ $BAR ]]
  done
}

@test "Eggdrop sets all allowed channel user flags for a user" {
  run bash -c '( FOO=$@; sleep 3; echo "testuser1"; echo "$PASS"; sleep 1; for i in ${FOO}; do echo ".chattr uuu -abcdefghjklmnopqrtuvwxyz #foober"; echo ".chattr uuu +${i} #foober"; echo ".whois uuu"; sleep 1; done; sleep 1; echo ".quit"; ) |telnet localhost 1111' $CHANFLAGS
  echo ${output} > foo2
  for j in ${CHANFLAGS}; do
    BAR="chattr uuu \|\+($j)\sNo global flags for uuu\. Channel flags for uuu on #foober are now \+\S*\1\S*\."
    echo "Flag is $j"
    echo "$BAR"
    [[ ${output} =~ ${BAR} ]]
  done
}

@test "Eggdrop rejects all non-allowed channel user flags for a user" {
  run bash -c '( FOO=$@; sleep 3; echo "testuser1"; echo "$PASS"; sleep 1; for i in ${FOO}; do echo ".chattr uuu -abcdefghjklmnopqrtuvwxyz #foober"; echo ".chattr uuu +${i} #foober"; echo ".whois uuu"; sleep 1; done; sleep 1; echo ".quit"; ) |telnet localhost 1111' $NONCHANFLAGS
  echo ${output} > foo3
  for j in ${NONCHANFLAGS}; do
    BAR="chattr uuu \|\+($j)\sNo global flags for uuu\. Channel flags for uuu on #foober are now \+\S*\1\S*\."
    echo "Flag is $j"
    [[ ! ${output} =~ ${BAR} ]]
  done
}

@test "Eggdrop sets all allowed channel bot flags for a bot" {
  run bash -c '( echo "testuser1"; echo "$PASS"; echo ".botattr bbb +s"; echo ".whois bbb"; echo ".botattr bbb -abcdefghjklmnopqrtuvwxyz"; sleep 1; echo ".quit"; ) |telnet localhost 1111'
  BAR="botattr bbb \|\+(s)\sBot flags for bbb on #foober are now \+\S*\1\S*\."
  [[ ${output} =~ $BAR ]]
}

@test "Eggdrop rejects all non-allowed channel bot flags for a bot" {
  run bash -c '( FOO=$@; sleep 3; echo "testuser1"; echo "$PASS"; for i in ${FOO}; do echo ".botattr bbb +${i} #foober"; echo ".whois bbb"; echo ".botattr bbb -abcdefghjklmnopqrtuvwxyz #foober"; sleep 1; done; sleep 1; echo ".quit"; ) |telnet localhost 1111' $NBCFLAGS
  echo ${output} > foo4
  for j in ${NBCFLAGS}; do
    BAR="botattr bbb \|\+($j)\sBot flags for bbb on #foober are now \+\S*\1\S*\."
    [[ ! ${output} =~ $BAR ]]
  done
}

@test "The +g flag can only be added if the s or p flags are present" {
skip
}

@test "The g flag is removed if the s or p flags are removed" {
skip
}


@test "Free Parking" {
  run bash -c 'reply=$(echo {die} |nc localhost 45678); echo $reply | cut -d "{" -f2 | cut -d "}" -f1'
  [ $status -eq 0 ]
}


### Test bot flags on user, vice versa?
