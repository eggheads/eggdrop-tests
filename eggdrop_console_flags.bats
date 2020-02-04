@test "Eggdrop setup" {
  run cp $WORK_DIR/tests/eggdrop_console_flags.* $HOME/eggdrop/
  echo $output
  [ $status -eq 0 ]
  run cp $WORK_DIR/tests/cmd_accept.tcl $HOME/eggdrop/scripts/
  [ $status -eq 0 ]
  cd $HOME/eggdrop
  run ./eggdrop eggdrop_console_flags.conf 3>&-
  [ $status -eq 0 ]
  run bash -c 'echo "{adduser testuser1}" |nc localhost 45678'
  [[ "$output" == *"{1}"* ]]
  run bash -c 'echo "{adduser testuser2}" |nc localhost 45678'
  [[ "$output" == *"{1}"* ]]
  run bash -c 'echo "{setuser testuser1 PASS eggdrop}" |nc localhost 45678'
  [[ "$output" == "0"* ]]
  run bash -c 'echo "{setuser testuser2 PASS eggdrop}" |nc localhost 45678'
  [[ "$output" == "0"* ]]
  run bash -c 'echo "{chattr testuser1 +n}" |nc localhost 45678'
  [[ "$output" == *"jlmnoptx"* ]]
  run bash -c 'echo "{chattr testuser2 +n}" |nc localhost 45678'
  [[ "$output" == *"jlmnoptx"* ]]
}


@test "Eggdrop sets default console flags from config" {
  run bash -c '{ echo "testuser1"; echo "$PASS"; echo ".console"; sleep 1; } | telnet localhost 3015'
  CON=${output##*Your console is}
  echo $CON
  [[ "$CON" == *" mcobx "* ]]
}


@test "Eggdrop sets console flags" {
  run bash -c '{ echo "testuser1"; echo "$PASS"; echo ".console +d"; sleep 1; } | telnet localhost 3015'
  CON=${output##*Set your console to}
  echo $CON
  [[ "$CON" == *" mcobxd "* ]]
}


@test "Eggdrop removes console flags" {
  run bash -c '{ echo "testuser1"; echo "$PASS"; echo ".console -d"; sleep 1; } | telnet localhost 3015'
  CON=${output##*Set your console to}
  echo $CON
  [[ "$CON" == *" mcobx "* ]]
}


@test "Eggdrop disallows adding invalid console flags" {
  run bash -c '{ echo "testuser1"; echo "$PASS"; echo ".console +z"; sleep 1; } | telnet localhost 3015'
  CON=${output##*Set your console to}
  echo $CON
  [[ "$CON" == *" mcobx "* ]]
}


@test "Eggdrop ignores removing invalid console flags" {
  run bash -c '{ echo "testuser1"; echo "$PASS"; echo ".console -z"; sleep 1; } | telnet localhost 3015'
  CON=${output##*Set your console to}
  echo $CON
  [[ "$CON" == *" mcobx "* ]]
}

@test "Eggdrop ignores adding already-set console flags" {
  run bash -c '{ echo "testuser1"; echo "$PASS"; echo ".console +m"; sleep 1; } | telnet localhost 3015'
  CON=${output##*Set your console to}
  echo $CON
  [[ "$CON" == *" mcobx "* ]]
}


@test "Eggdrop ignores removing non-set console flags" {
  run bash -c '{ echo "testuser1"; echo "$PASS"; echo ".console -d"; sleep 1; } | telnet localhost 3015'
  CON=${output##*Set your console to}
  echo $CON
  [[ "$CON" == *" mcobx "* ]]
}


@test "Eggdrop sets console flags and changes channel view" {
  run bash -c '{ echo "testuser1"; echo "$PASS"; echo ".console #testegg +d"; sleep 1; } | telnet localhost 3015'
  CON=${output##*Set your console to}
  echo $CON
  [[ "$CON" == *"#testegg: mcobxd "* ]]
}


@test "Eggdrop removes console flags and changes channel view" {
  run bash -c '{ echo "testuser1"; echo "$PASS"; echo ".console * -d"; sleep 1; } | telnet localhost 3015' 
  CON=${output##*Set your console to}
  echo $CON 
  [[ "$CON" == *"*: mcobx "* ]]
} 


@test "Eggdrop changes channel view" {
  run bash -c '{ echo "testuser1"; echo "$PASS"; echo ".console #testegg"; sleep 1; } | telnet localhost 3015'
  CON=${output##*Set your console to}
  echo $CON
  [[ "$CON" == *"#testegg: mcobx "* ]]
}

@test "Eggdrop shows console for other user" {
skip
}


@test "Eggdrop sets console flags for other user" {
skip
}

@test "Eggdrop removes console flags for other user" {
skip
}

@test "Eggdrop sets console flags and changes channel view for other user" {
skip
}

@test "Eggdrop removes console flags and changes channel view for other user" {
skip
}

@test "Eggdrop changes channel view for other user" {
skip
}

@test "Eggdrop .resetconsole resets to config default (on channel)" {
skip
  run bash -c '{ echo "testuser1"; echo "$PASS"; echo ".console #testegg +d"; echo ".resetconsole"; sleep 1; } | telnet localhost 3015'
  CON=${output##*Set your console to}
  [[ "$CON" == *"*: mcobx "* ]]
}

@test "Eggdrop .resetconsole resets to config defaults (on *)" {
skip
  run bash -c '{ echo "testuser1"; echo "$PASS"; echo ".console * +d"; echo ".resetconsole"; sleep 1; } | telnet localhost 3015'
  CON=${output##*Set your console to}
  [[ "$CON" == *"*: mcobx "* ]]
}

@test "Kill Eggdrop" {
  ps x|grep "[e]ggdrop "
  if [ $? -eq 0 ]; then
    pkill eggdrop
  fi
  if [ -e $HOME/eggdrop/tempuser.user ]; then
    rm $HOME/eggdrop/tempsuer.user
  fi
}
