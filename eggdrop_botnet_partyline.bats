@test "Eggdrop setup" {
  run cp $WORK_DIR/tests/eggdrop_botnet_partyline* $HOME/eggdrop/
  [ $status -eq 0 ]
  run cp $WORK_DIR/tests/eggdrop_botnet_partyline-nossl* $HOME/nossl/
  [ $status -eq 0 ]
  run cp $WORK_DIR/tests/eggdrop_botnet_partyline-noipv6* $HOME/noipv6/
  [ $status -eq 0 ]
  run cp $WORK_DIR/tests/cmd_accept.tcl $HOME/eggdrop/scripts/
  [ $status -eq 0 ]
  cp $WORK_DIR/tests/cmd_accept.tcl $HOME/nossl/scripts/cmd_accept3.tcl
  cp $HOME/eggdrop/scripts/cmd_accept.tcl $HOME/noipv6/scripts/cmd_accept4.tcl
  run sed -i 's/45678/34567/g' $HOME/nossl/scripts/cmd_accept3.tcl
  run sed -i 's/45678/54321/g' $HOME/noipv6/scripts/cmd_accept4.tcl
  [ $status -eq 0 ]
  cd $HOME/eggdrop
  run ./eggdrop eggdrop_botnet_partyline1.conf
  echo $output
  [ $status -eq 0 ]
  cd $HOME/nossl
  run ./eggdrop eggdrop_botnet_partyline-nossl.conf 3>&-
  echo $output
  [ $status -eq 0 ]
  cd $HOME/noipv6
  run ./eggdrop eggdrop_botnet_partyline-noipv6.conf 3>&-
  echo $output
  [ $status -eq 0 ]
}


@test "Non-SSL Eggdrop denies adding bot with (+)dest port (one argument)" {
  echo "{deluser testbot}" |nc localhost 34567
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot 1.1.1.1 +1111"; sleep 2; } | telnet localhost 3311'
  echo $output
  [[ ${output} == *"Ports prefixed with '+' are not enabled (this Eggdrop was compiled without TLS support)"* ]]
}


@test "Non-SSL Eggdrop denies adding bot with (+)dest bot port" {
  echo "{deluser testbot}" |nc localhost 34567
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot 1.1.1.1 +1111/2222"; sleep 2; } | telnet localhost 3311'
  [[ ${output} == *"Ports prefixed with '+' are not enabled (this Eggdrop was compiled without TLS support)"* ]]
}


@test "Non-SSL Eggdrop denies adding bot with (+)dest user port" {
  echo "{deluser testbot}" |nc localhost 34567
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot 1.1.1.1 1111/+2222"; sleep 2; } | telnet localhost 3311'
  [[ ${output} == *"Ports prefixed with '+' are not enabled (this Eggdrop was compiled without TLS support)"* ]]
}


@test "Non-SSL Eggdrop denies adding bot with (+)dest user and bot port" {
  echo "{deluser testbot}" |nc localhost 34567
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot 1.1.1.1 +1111/+2222"; sleep 2; } | telnet localhost 3311'
  [[ ${output} == *"Ports prefixed with '+' are not enabled (this Eggdrop was compiled without TLS support)"* ]]
}


@test "Eggdrop denies adding bot with hostname containing a /" {
  echo "{deluser testbot}" |nc localhost 34567
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot 2222/3333"; sleep 2; } | telnet localhost 3311'
  echo $output
  [[ ${output} == *"Bot address may not contain a '/'."* ]]
}


@test "Eggdrop denies adding bot with hostname containing +" {
  echo "{deluser testbot}" |nc localhost 34567
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot +1111"; sleep 2; } | telnet localhost 3311'
  echo $output
  [[ ${output} == *"Bot address may not contain a '+'"* ]]
}


@test "Eggdrop denies adding bot with hostname containing all numbers, no periods" {
  echo "{deluser testbot}" |nc localhost 34567
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot 11111 1111"; sleep 2; } | telnet localhost 3311'
  echo $output
  [[ ${output} == *"Invalid host address."* ]]
}


@test "Eggdrop allows adding bot with hostname containing IPv4 address only" {
  echo "{deluser testbot}" |nc localhost 34567
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot 1.1.1.1"; sleep 2; } | telnet localhost 3311'
  echo $output
  [[ ${output} == *"Added bot 'testbot' with address [1.1.1.1]:3333/3333"* ]]
}


@test "Eggdrop allows adding bot with hostname containing IPv6 address only with IPv6 enabled" {
  echo "{deluser testbot}" |nc localhost 34567
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot fd15:4ba5:5a2b:1008:20c:29ff:fe02"; sleep 2; } | telnet localhost 3311'
  [[ ${output} == *"Added bot 'testbot' with address [fd15:4ba5:5a2b:1008:20c:29ff:fe02]:3333/3333"* ]]
}


@test "Eggdrop prevents adding bot IPv6 address when IPv6 disabled" {
  echo "{deluser testbot}" |nc localhost 54321
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot fd15:4ba5:5a2b:1008:20c:29ff:fe02"; sleep 2; } | telnet localhost 4311'
  echo ${output}
  [[ ${output} == *"Invalid IP address format (this Eggdrop was compiled without IPv6 support)."* ]]
}


@test "Eggdrop allows adding bot with IPv4 address and bot port" {
  echo "{deluser testbot}" |nc localhost 34567
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot 1.1.1.1 2222"; sleep 2; } | telnet localhost 3311'
  echo $output
  [[ ${output} == *"Added bot 'testbot' with address [1.1.1.1]:2222/2222"* ]]
}


@test "Eggdrop allows adding bot with IPv4 address and bot and user port" {
  echo "{deluser testbot}" |nc localhost 34567
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot 1.1.1.1 2222/5555"; sleep 2; } | telnet localhost 3311'
  [[ ${output} == *"Added bot 'testbot' with address [1.1.1.1]:2222/5555"* ]]
}

@test "Eggdrop denies adding bot with more than 2 ports specified" {
  echo "{deluser testbot}" |nc localhost 34567
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot 1.1.1.1 2222/5555/6666"; sleep 2; } | telnet localhost 3311'
  [[ ${output} == *"You've supplied more than 2 ports, make up your mind."* ]]
}

@test "Eggdrop denies changing a bot to more than 2 ports" {
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".chaddr testbot 1.1.1.1 2222/5555/6666"; sleep 2; } | telnet localhost 3311'
  [[ ${output} == *"You've supplied more than 2 ports, make up your mind."* ]]
}

@test "Eggdrop allows adding bot with hostname" {
  echo "{deluser testbot}" |nc localhost 34567
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot foo.bar.com"; sleep 2; } | telnet localhost 3311'
  [[ ${output} == *"Added bot 'testbot' with address [foo.bar.com]:3333/3333"* ]]
}


@test "SSL Eggdrop adds bot containing +port format to both bot and user port" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c 'echo "{status}" |nc localhost 45678'
  [[ "${output}" == *"tls {OpenSSL "* ]]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot 1.1.1.1 +1111"; sleep 2; } | telnet localhost 1111'
  echo $output
  [[ ${output} == *"Added bot 'testbot' with address [1.1.1.1]:+1111/+1111"* ]]
}


@test "SSL Eggdrop allows adding bot containing port/+port format" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c 'echo "{status}" |nc localhost 45678'
  [[ "${output}" == *"tls {OpenSSL "* ]] 
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot 1.1.1.1 1111/+2222"; sleep 2; } | telnet localhost 1111'
  echo $output
  [[ ${output} == *"Added bot 'testbot' with address [1.1.1.1]:1111/+2222"* ]]
}


@test "SSL Eggdrop resets from +port to port when non-SSL specified" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c 'echo "{status}" |nc localhost 45678'
  [[ "${output}" == *"tls {OpenSSL "* ]]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot 1.1.1.1 +1111/+2222"; sleep 2; } | telnet localhost 1111'
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ ${output} == *"0 {1.1.1.1 +1111 +2222}"* ]]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".chaddr testbot 1.1.1.1 1111/2222"; sleep 2; } | telnet localhost 1111'
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ ${output} == *"0 {1.1.1.1 1111 2222}"* ]]
}


@test "Eggdrop allows changing bot address with hostname containing IPv4 address only" {
  echo "{deluser testbot}" |nc localhost 45678
  echo "{addbot testbot 9.9.9.9}" |nc localhost 45678
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".chaddr testbot 1.1.1.1"; sleep 2; } | telnet localhost 1111'
  [[ ${output} == *"Changed bot's address"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  echo $output
  [[ ${output} == *"0 {1.1.1.1 3333 3333}"* ]]
}


@test "Eggdrop changes both user and bot ports to same value when given IPv4 address and only bot port" {
  echo "{deluser testbot}" |nc localhost 45678
  echo "{addbot testbot 9.9.9.9}" |nc localhost 45678
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".chaddr testbot 1.1.1.1 1111"; sleep 2; } | telnet localhost 1111'
  [[ ${output} == *"Changed bot's address"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ ${output} == *"0 {1.1.1.1 1111 1111}"* ]]
}


@test "Eggdrop allows changing bot address with IPv4 address and bot and user port" {
  echo "{deluser testbot}" |nc localhost 45678
  echo "{addbot testbot 9.9.9.9}" |nc localhost 45678
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".chaddr testbot 1.1.1.1 2222/4444"; sleep 2; } | telnet localhost 1111'
  [[ ${output} == *"Changed bot's address"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ ${output} == *"0 {1.1.1.1 2222 4444}"* ]]
}


@test "Eggdrop allows changing bot address with hostname" {
  echo "{deluser testbot}" |nc localhost 45678
  echo "{addbot testbot 9.9.9.9}" |nc localhost 45678
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".chaddr testbot foo.com"; sleep 2; } | telnet localhost 1111'
  [[ ${output} == *"Changed bot's address"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ ${output} == *"0 {foo.com 3333 3333}"* ]]
}


@test "Eggdrop allows changing bot address containing +port format" {
  echo "{deluser testbot}" |nc localhost 45678
  echo "{addbot testbot 9.9.9.9}" |nc localhost 45678
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".chaddr testbot 1.1.1.1 +3333"; sleep 2; } | telnet localhost 1111'
  [[ ${output} == *"Changed bot's address"* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ ${output} == *"0 {1.1.1.1 +3333 +3333}"* ]]
}


@test "Eggdrop prevents changing bot to IPv6 address when IPv6 disabled" {
  echo "{deluser testbot}" |nc localhost 45678
  echo "{addbot testbot 9.9.9.9}" |nc localhost 54321
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".chaddr testbot fd15:4ba5:5a2b:1008:20c:29ff:fe02"; sleep 2; } | telnet localhost 4311'
  [[ ${output} == *"Invalid IP address format (this Eggdrop was compiled without IPv6 support)."* ]]
}


@test "Eggdrop prevents ports being added above 65535" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot 1.1.1.1 65536"; sleep 2; } | telnet localhost 1111'
  [[ ${output} == *"Ports must be integers between 1 and 65535."* ]]
}


@test "Eggdrop prevents ports being added below 1" {
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot 1.1.1.1 -2"; sleep 2; } | telnet localhost 1111'
  [[ ${output} == *"Ports must be integers between 1 and 65535."* ]]
}


@test "Eggdrop prevents ports being added containing chars" {
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot 1.1.1.1 7of9"; sleep 2; } | telnet localhost 1111'
  [[ ${output} == *"Ports must be integers between 1 and 65535."* ]]
}


@test "Eggdrop prevents ports being changed to above 65535" {
  echo "{addbot testbot 9.9.9.9}" |nc localhost 45678
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".chaddr testbot 1.1.1.1 65536"; sleep 2; } | telnet localhost 1111'
  [[ ${output} == *"Ports must be integers between 1 and 65535."* ]]
}

@test "Eggdrop prevents ports being changed to below 1" {
  echo "{addbot testbot 9.9.9.9}" |nc localhost 45678 
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".chaddr testbot 1.1.1.1 -2"; sleep 2; } | telnet localhost 1111'
  [[ ${output} == *"Ports must be integers between 1 and 65535."* ]]
}


@test "Eggdrop prevents ports being changed to contain chars" {
  echo "{addbot testbot 9.9.9.9}" |nc localhost 45678
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".chaddr testbot 1.1.1.1 7of9"; sleep 2; } | telnet localhost 1111'
  [[ ${output} == *"Ports must be integers between 1 and 65535."* ]]
}

@test "Eggdrop denies changing a bot to more than 2 ports" {
  echo "{addbot testbot 9.9.9.9}" |nc localhost 34567
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".chaddr testbot 1.1.1.1 2222/5555/6666"; sleep 2; } | telnet localhost 3311'
  [[ ${output} == *"You've supplied more than 2 ports, make up your mind."* ]]
}

@test "Eggdrop allows adding IPv6 address in xxxx:yyyy format" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4492"; sleep 2; } | telnet localhost 1111'
  [[ ${output} == *"Added bot 'testbot' with address [fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4492]:3333/3333 and no hostmask."* ]]
}

@test "Eggdrop allows changing to IPv6 address in xxxx::yyyy format" {
  echo "{addbot testbot fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4492}" | nc localhost 45678
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".chaddr testbot fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4493"; sleep 2; } | telnet localhost 1111'
  [[ ${output} == *"Changed bot's address."* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ ${output} == *"0 {fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4493 3333 3333}"* ]]
}

@test "Eggdrop allows adding IPv6 in [xxxx::yyyy] format" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot [fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4492]"; sleep 2; } | telnet localhost 1111' 
  [[ ${output} == *"Added bot 'testbot' with address [fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4492]:3333/3333 and no hostmask."* ]]
}

@test "Eggdrop allows changing to IPv6 in [xxxx::yyyy] format" {
  echo "{addbot testbot fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4492}" | nc localhost 45678
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".chaddr testbot [fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4493]"; sleep 2; } | telnet localhost 1111'
  [[ ${output} == *"Changed bot's address."* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ ${output} == *"0 {fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4493 3333 3333}"* ]]
}

@test "Eggdrop allows adding IPv6 in '[xxxx::yyyy] port' format" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot [fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4492] 4444"; sleep 2; } | telnet localhost 1111'
  [[ ${output} == *"Added bot 'testbot' with address [fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4492]:4444/4444 and no hostmask."* ]]
}

@test "Eggdrop allows changing to IPv6 in '[xxxx::yyyy] port' format" {
  echo "{addbot testbot fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4492}" | nc localhost 45678
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".chaddr testbot [fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4493] 4444"; sleep 2; } | telnet localhost 1111'
  [[ ${output} == *"Changed bot's address."* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ ${output} == *"fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4493 4444 4444"* ]]
}

@test "Eggdrop allows adding IPv6 in '[xxxx::yyyy] port/port' format" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot [fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4492] 4444/5555"; sleep 2; } | telnet localhost 1111'
  [[ ${output} == *"Added bot 'testbot' with address [fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4492]:4444/5555 and no hostmask."* ]]
}

@test "Eggdrop allows changing to IPv6 in '[xxxx::yyyy] port/port' format" {
  echo "{addbot testbot fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4492}" | nc localhost 45678
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".chaddr testbot [fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4493] 4444/5555"; sleep 2; } | telnet localhost 1111'
  [[ ${output} == *"Changed bot's address."* ]]
  run bash -c 'echo "{getuser testbot botaddr}" |nc localhost 45678'
  [[ ${output} == *"fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4493 4444 5555"* ]]
}


@test "Eggdrop allows adding bot with <handle> <address> <host> format" {
  echo "{deluser testbot}" |nc localhost 45678
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".+bot testbot [fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4492] 4444/5555 *!*@*.foo.com"; sleep 2; } | telnet localhost 1111'
  [[ ${output} == *"Added bot 'testbot' with address [fd15:4ba5:5a2b:1008:c5c6:bbd0:483e:4492]:4444/5555 and hostmask '*!*@*.foo.com'."* ]]
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
