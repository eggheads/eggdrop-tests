@test "Eggdrop setup" {
  run cp $WORK_DIR/tests/eggdrop_tcl_addbot* $HOME/eggdrop/
  [ $status -eq 0 ]
  run cp $WORK_DIR/tests/eggdrop_botnet_partyline-noipv6* $HOME/noipv6/
  [ $status -eq 0 ]
  run cp $WORK_DIR/tests/cmd_accept.tcl $HOME/eggdrop/scripts/
  [ $status -eq 0 ]
  cp $HOME/eggdrop/scripts/cmd_accept.tcl $HOME/noipv6/scripts/cmd_accept4.tcl
  run sed -i 's/45678/54321/g' $HOME/noipv6/scripts/cmd_accept4.tcl
  [ $status -eq 0 ]
  cd $HOME/eggdrop
  run ./eggdrop -m eggdrop_tcl_addbot.conf
  [ $status -eq 0 ]
  cd $HOME/noipv6
  run ./eggdrop eggdrop_botnet_partyline-noipv6.conf
  [ $status -eq 0 ]
}

@test "addbot adds bot record in 'addbot handle ipv4address' format" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c 'echo "{addbot testbot 1.1.1.1}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ "${output}" == *"0 {1.1.1.1 3333 3333}"* ]]
}

@test "addbot adds bot record in 'addbot handle ipv6address' format" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c 'echo "{addbot testbot fe80::69ec:cfe4:81de:4fe5}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ "${output}" == *"0 {fe80::69ec:cfe4:81de:4fe5 3333 3333}"* ]]
}

@test "addbot adds bot record in 'addbot handle ipv4address botport' format" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c 'echo "{addbot testbot 1.1.1.1 5555}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ "${output}" == *"0 {1.1.1.1 5555 5555}"* ]]
}

@test "addbot adds bot record in 'addbot handle ipv6address botport' format" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c 'echo "{addbot testbot fe80::69ec:cfe4:81de:4fe5 6666}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ "${output}" == *"0 {fe80::69ec:cfe4:81de:4fe5 6666 6666}"* ]]
}

@test "addbot adds bot record in 'addbot handle ipv4 address botport userport' format" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c 'echo "{addbot testbot 1.1.1.1 5555 6666}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ "${output}" == *"0 {1.1.1.1 5555 6666}"* ]]
}

@test "addbot adds bot record in 'addbot handle ipv6 address botport userport' format" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c 'echo "{addbot testbot fe80::69ec:cfe4:81de:4fe5 6666 7777}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ "${output}" == *"0 {fe80::69ec:cfe4:81de:4fe5 6666 7777}"* ]]
}

@test "addbot adds bot record in 'addbot handle ipv4address:botport' format" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c 'echo "{addbot testbot 1.1.1.1:4444}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ "${output}" == *"0 {1.1.1.1 4444 4444}"* ]]
}

#@test "addbot adds bot record in 'addbot handle ipv4address/botport' format" {
#  echo "{deluser testbot}" |nc localhost 45678
#  run bash -c 'echo "{addbot testbot 1.1.1.1/4444}" |nc localhost 45678'
#  [[ "${output}" == *"0 {1}"* ]]
#  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
#  [[ "${output}" == *"0 {1.1.1.1 4444 4444}"* ]]
#}

#@test "addbot adds bot record in 'addbot handle ipv6address/botport' format" {
#  echo "{deluser testbot}" |nc localhost 45678
#  run bash -c 'echo "{addbot testbot fe80::69ec:cfe4:81de:4fe5/4444}" |nc localhost 45678'
#  [[ "${output}" == *"0 {1}"* ]]
#  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
#  [[ "${output}" == *"0 {fe80::69ec:cfe4:81de:4fe5 4444 4444}"* ]]
#}

#@test "addbot adds bot record in 'addbot handle ipv4address/botport/userport' format" {
#  echo "{deluser testbot}" |nc localhost 45678
#  run bash -c 'echo "{addbot testbot 1.1.1.1/4444/5555}" |nc localhost 45678'
#  [[ "${output}" == *"0 {1}"* ]]
#  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
#  [[ "${output}" == *"0 {1.1.1.1 4444 5555}"* ]]
#}

#@test "addbot adds bot record in 'addbot handle ipv6address/botport/userport' format" {
#  echo "{deluser testbot}" |nc localhost 45678
#  run bash -c 'echo "{addbot testbot fe80::69ec:cfe4:81de:4fe5/4444/5555}" |nc localhost 45678'
#  [[ "${output}" == *"0 {1}"* ]]
#  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
#  [[ "${output}" == *"0 {fe80::69ec:cfe4:81de:4fe5 4444 5555}"* ]]
#}


#@test "addbot rejects bot record in 'addbot handle ipaddress botport' format" {
#  echo "{deluser testbot}" |nc localhost 45678
#  run bash -c 'echo "{addbot testbot 1.1.1.1 5555}" |nc localhost 45678'
#  [[ "${output}" == *"1 {wrong # args: should be \"addbot handle address\"}"* ]]
#}

@test "addbot ignores additional arguments if address arg uses :s" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c 'echo "{addbot testbot 1.1.1.1:4444/5555 6666}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ "${output}" == *"0 {1.1.1.1 4444 5555}"* ]]
}

@test "addbot allows bot record in 'addbot handle \[ipv6address\]:botport' format" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c 'echo "{addbot testbot \[fe80::69ec:cfe4:81de:4fe5\]:4444}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ "${output}" == *"0 {fe80::69ec:cfe4:81de:4fe5 4444 4444}"* ]]
}

@test "addbot allows bot record in 'addbot handle \[ipv6address\]:botport/userport' format" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c 'echo "{addbot testbot \[fe80::69ec:cfe4:81de:4fe5\]:4444/5555}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ "${output}" == *"0 {fe80::69ec:cfe4:81de:4fe5 4444 5555}"* ]]
}

@test "addbot allows bot record in 'addbot handle \[ipv6address\] botport' format" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c 'echo "{addbot testbot \[fe80::69ec:cfe4:81de:4fe5\] 4444}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ "${output}" == *"0 {fe80::69ec:cfe4:81de:4fe5 4444 4444}"* ]]
}

@test "addbot allows bot record in 'addbot handle \[ipv6address\] botport userport' format" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c 'echo "{addbot testbot \[fe80::69ec:cfe4:81de:4fe5\] 4444 5555}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ "${output}" == *"0 {fe80::69ec:cfe4:81de:4fe5 4444 5555}"* ]]
}

@test "addbot allows bot record in 'addbot handle ipv6address/' format with default ports" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c 'echo "{addbot testbot fe80::69ec:cfe4:81de:4fe5/}" |nc localhost 45678'
  [[ "${output}" == *"0 {1}"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ "${output}" == *"0 {fe80::69ec:cfe4:81de:4fe5 3333 3333}"* ]]
}

@test "reject ipv4 with braces" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c 'echo "{addbot testbot \[1.1.1.1\] |nc localhost 45678'
}

@test "Non-IPv6 bot rejects IPv6 address" {
  echo "{deluser testbot}" |nc localhost 54321
  run bash -c 'echo "{addbot testbot fe80::69ec:cfe4:81de:4fe5}" |nc localhost 54321'
  [[ "${output}" == *"0 {0}"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
    [[ "${output}" == *"1 {No such user.}"* ]]
}

@test "Non-SSL Eggdrop rejects TLS port" {
skip
}

@test "addbot rejects port < 1" {
  run bash -c 'echo "{addbot testbot 1.1.1.1 0}" |nc localhost 54321'
  [[ "${output}" == *"0 {0}"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ "${output}" == *"1 {No such user.}"* ]]
}

@test "Eggdrop rejects port > 65565" {
  run bash -c 'echo "{addbot testbot 1.1.1.1 65536}" |nc localhost 54321'
  [[ "${output}" == *"0 {0}"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ "${output}" == *"1 {No such user.}"* ]]
}

#@test "Eggdrop rejects >5 addbot arguments" {
#  echo "{deluser testbot}" |nc localhost 45678
#  run bash -c 'echo "{addbot testbot 1.1.1.1 3333 4444 5555}" |nc localhost 45678'
#  [[ "${output}" == *"1 {wrong # args: should be "addbot handle address ?telnet-port ?relay-port??"}"* ]]
#  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
#  [[ "${output}" == *"0 {fe80::69ec:cfe4:81de:4fe5 3333 3333}"* ]]
#}

@test "Kill Eggdrop" {
  ps x|grep "[e]ggdrop "
  if [ $? -eq 0 ]; then
    pkill eggdrop
  fi
  if [ -e $HOME/eggdrop/tempuser.user ]; then
    rm $HOME/eggdrop/tempsuer.user
  fi
}
