@test "Eggdrop setup" {
  run cp /tmp/build/tests/eggdrop_botnet_linking* /home/eggdrop/eggdrop/
  [ $status -eq 0 ]
  run cp /tmp/build/tests/eggdrop_botnet_linking* /home/eggdrop/nossl/
  [ $status -eq 0 ]
  [ $status -eq 0 ]
  run cp /tmp/build/tests/cmd_accept.tcl /home/eggdrop/eggdrop/scripts/
  [ $status -eq 0 ]
  cp /home/eggdrop/eggdrop/scripts/cmd_accept.tcl /home/eggdrop/eggdrop/scripts/cmd_accept2.tcl
  cp /home/eggdrop/eggdrop/scripts/cmd_accept.tcl /home/eggdrop/nossl/scripts/cmd_accept3.tcl
  run sed -i 's/45678/56789/g' /home/eggdrop/eggdrop/scripts/cmd_accept2.tcl
  run sed -i 's/45678/34567/g' /home/eggdrop/nossl/scripts/cmd_accept3.tcl
  [ $status -eq 0 ]
  run ./eggdrop eggdrop_botnet_linking1.conf
  [ $status -eq 0 ]
  run ./eggdrop eggdrop_botnet_linking2.conf
  [ $status -eq 0 ]
  cd ../nossl
  run ./eggdrop eggdrop_botnet_linking-nossl.conf
  [ $status -eq 0 ]
### Add bot1 to bot2
  run bash -c 'echo "{addbot bot1 localhost:1111}" |nc localhost 56789'
  [ "${output}"="0 {1}" ]
### Add bot3 to bot2
  run bash -c 'echo "{addbot bot1 localhost:3311}" |nc localhost 56789'
  [ "${output}"="0 {1}" ]
### Add bot2 to bot1
  run bash -c 'echo "{addbot bot2 localhost:2222}" |nc localhost 45678'
  [ "${output}"="0 {1}" ]
### Add bot3 to bot1
  run bash -c 'echo "{addbot bot3 localhost:3311}" |nc localhost 45678'
  [ "${output}"="0 {1}" ]
### Add bot1 to bot3
  run bash -c 'echo "{addbot bot1 localhost:1111}" |nc localhost 34567'
  [ "${output}"="0 {1}" ]
### Add bot2 to bot3
  run bash -c 'echo "{addbot bot2 localhost:2222}" |nc localhost 34567'
  [ "${output}"="0 {1}" ]
}


@test "SSL leaf with (-)dest port connects with SSL to SSL hub listening on (-) all" {
  echo "{unlink bot1}" |nc localhost 56789
  sleep 3
  run bash -c 'echo "{setuser bot1 botaddr localhost 1111 1111}" |nc localhost 56789'
  [ ${output}="0 {}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".link bot1"; sleep 2; } | telnet localhost 2222'
  echo $output
  [[ ${output} == *" Linked to bot1"* ]]
  [[ ${output} == *"TLS: handshake successful. Secure connection established."* ]]
}


@test "SSL leaf with (-)dest port connects with SSL to SSL hub listening on (-) bots" {
  echo "{unlink bot1}" |nc localhost 56789
  sleep 3
  run bash -c 'echo "{setuser bot1 botaddr localhost 1113 1113}" |nc localhost 56789'
  [ ${output}="0 {}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".link bot1"; sleep 2; } | telnet localhost 2222'
  echo $output 
  [[ ${output} == *" Linked to bot1"* ]]
  [[ ${output} == *"TLS: handshake successful. Secure connection established."* ]]
}


@test "SSL leaf with (-)dest port connects with SSL to SSL hub listening on (+) all" {
skip "Failed - read client hellos, no handshake"
  echo "{unlink bot1}" |nc localhost 56789
  echo "{unlink bot2}" |nc localhost 45678
  sleep 3
  run bash -c 'echo "{setuser bot1 botaddr localhost 1121 1121}" |nc localhost 56789'
  [ ${output}="0 {}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".link bot1"; sleep 3; } | telnet localhost 2222'
  echo $output 
  [[ ${output} == *" Linked to bot1"* ]]
  [[ ${output} == *"TLS: handshake successful. Secure connection established."* ]]
}


@test "SSL leaf with (-)dest port connects with SSL to SSL hub listening on (+) bots" {
skip "Failed - read client hellos, no handshake"
  echo "{unlink bot1}" |nc localhost 56789
  echo "{unlink bot2}" |nc localhost 45678
  sleep 3
  run bash -c 'echo "{setuser bot1 botaddr localhost 1123 1123}" |nc localhost 56789'
  [ ${output}="0 {}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".link bot1"; sleep 2; } | telnet localhost 2222'
  echo $output
  [[ ${output} == *" Linked to bot1"* ]]
  [[ ${output} == *"TLS: handshake successful. Secure connection established."* ]]
}


@test "SSL leaf with (+)dest port connects with SSL to SSL hub listening on (-) all" {
skip "Failed - ERROR linking bot1: Only users may connect at this port."
  echo "{unlink bot1}" |nc localhost 56789
  sleep 3
  run bash -c 'echo "{setuser bot1 botaddr localhost +1111 +1111}" |nc localhost 56789'
  [ ${output}="0 {}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".link bot1"; sleep 2; } | telnet localhost 2222'
  echo $output
  [[ ${output} == *" Linked to bot1"* ]]
  [[ ${output} == *"TLS: handshake successful. Secure connection established."* ]]
}


@test "SSL leaf with (+)dest port connects with SSL to SSL hub listening on (-) bots" {
skip "Failed - No error, hub sees connection but then just fails"
  echo "{unlink bot1}" |nc localhost 56789
  sleep 3
  run bash -c 'echo "{setuser bot1 botaddr localhost +1113 +1113}" |nc localhost 56789'
  [ ${output}="0 {}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".link bot1"; sleep 2; } | telnet localhost 2222'
  echo $output
  [[ ${output} == *" Linked to bot1"* ]]
  [[ ${output} == *"TLS: handshake successful. Secure connection established."* ]]
}


@test "SSL leaf with (+)dest port connects with SSL to SSL hub listening on (+) all" {
  echo "{unlink bot1}" |nc localhost 56789
  sleep 3
  run bash -c 'echo "{setuser bot1 botaddr localhost +1121 +1121}" |nc localhost 56789'
  [ ${output}="0 {}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".link bot1"; sleep 2; } | telnet localhost 2222'
  echo $output
  [[ ${output} == *" Linked to bot1"* ]]
  [[ ${output} == *"TLS: handshake successful. Secure connection established."* ]]

}


@test "SSL leaf with (+)dest port connects with SSL to SSL hub listening on (+) bots" {
  echo "{unlink bot1}" |nc localhost 56789
  sleep 3
  run bash -c 'echo "{setuser bot1 botaddr localhost +1123 +1123}" |nc localhost 56789'
  [ ${output}="0 {}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".link bot1"; sleep 2; } | telnet localhost 2222'
  echo $output
  [[ ${output} == *" Linked to bot1"* ]]
  [[ ${output} == *"TLS: handshake successful. Secure connection established."* ]]
}


@test "Non-SSL leaf with (-)dest port connects without SSL to SSL hub listening on (-) all" {
  echo "{unlink bot1}" |nc localhost 34567
  sleep 3
  run bash -c 'echo "{setuser bot1 botaddr localhost 1111 1111}" |nc localhost 34567'
  [ ${output}="0 {}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".link bot1"; sleep 2; } | telnet localhost 3311'
  echo $output
  [[ ${output} == *" Linked to bot1"* ]]
  [[ ${output} != *"TLS: handshake successful. Secure connection established."* ]]
}


@test "Non-SSL leaf with (-)dest port connects without SSL to SSL hub listening on (-) bots" {
  echo "{unlink bot1}" |nc localhost 34567
  sleep 3
  run bash -c 'echo "{setuser bot1 botaddr localhost 1113 1113}" |nc localhost 34567'
  [ ${output}="0 {}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".link bot1"; sleep 2; } | telnet localhost 3311'
  echo $output
  [[ ${output} == *" Linked to bot1"* ]]
  [[ ${output} != *"TLS: handshake successful. Secure connection established."* ]]
}


@test "Non-SSL leaf with (-)dest port denied connection to SSL hub listening on (+) all" {
skip "Failed - denied, but no error message given"
  echo "{unlink bot1}" |nc localhost 34567
  sleep 3
  run bash -c 'echo "{setuser bot1 botaddr localhost 1121 1121}" |nc localhost 34567'
  [ ${output}="0 {}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".link bot1"; sleep 2; } | telnet localhost 3311'
  echo $output
  [[ ${output} == *"Failed link to bot1."* ]]
}


@test "Non-SSL leaf with (-)dest port denied connection to SSL hub listening on (+) bots" {
skip "Failed - denied connection, but no error message"
  echo "{unlink bot1}" |nc localhost 34567
  sleep 3
  run bash -c 'echo "{status}" |nc localhost 34567'
  echo $output
  run bash -c 'echo "{setuser bot1 botaddr localhost 1123 1123}" |nc localhost 34567'
  [ ${output}="0 {}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".link bot1"; sleep 2; } | telnet localhost 3311'
  echo $output
  [ 1 -eq 0 ]
  [[ ${output} == *"Failed link to bot1."* ]]
}


@test "Non-SSL Eggdrop denies adding hub with (+)dest port " {
skip "Failed - but belongs in botnet_commandline suite"
}

@test "Eggdrop validates +bot/chaddr input" {
skip "Failed - but belongs in botnet_commandline suite"
}



@test "SSL leaf with (-)dest port connects without SSL to non-SSL hub listening on (-) all" {
  echo "{unlink bot3}" |nc localhost 56789
  sleep 3
  run bash -c 'echo "{setuser bot3 botaddr localhost 3313 3313}" |nc localhost 56789'
  [ ${output}="0 {}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".link bot3"; sleep 2; } | telnet localhost 2222'
  echo $output
  [[ ${output} == *" Linked to bot3"* ]]
  [[ ${output} != *"TLS: handshake successful. Secure connection established."* ]]
}


@test "SSL leaf with (-)dest port connects without SSL to non-SSL hub listening on (-) bots" {
  echo "{unlink bot3}" |nc localhost 56789
  sleep 3
  run bash -c 'echo "{setuser bot3 botaddr localhost 3313 3313}" |nc localhost 56789'
  [ ${output}="0 {}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".link bot3"; sleep 2; } | telnet localhost 2222'
  echo $output
  [[ ${output} == *" Linked to bot3"* ]]
  [[ ${output} != *"TLS: handshake successful. Secure connection established."* ]] 
}


@test "SSL leaf with (+)dest port denies connection to non-SSL hub listening on (-) all" {
skip "Failed - hub returned ERROR linking bot3: Only users may connect at this port."
  echo "{unlink bot3}" |nc localhost 56789
  sleep 3
  run bash -c 'echo "{setuser bot3 botaddr localhost +3311 +3311}" |nc localhost 56789'
  [ ${output}="0 {}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".link bot3"; sleep 2; } | telnet localhost 2222'
  echo $output
  [ 1 -eq 0 ]
  [[ ${output} == *" Linked to bot3"* ]]
  [[ ${output} != *"TLS: handshake successful. Secure connection established."* ]]
}

@test "SSL leaf with (+)dest port denies connection to non-SSL hub listening on (-) bots" {
skip "Failed - denied connection, but no error message"
  echo "{unlink bot3}" |nc localhost 56789
  sleep 3
  run bash -c 'echo "{setuser bot3 botaddr localhost +3313 +3313}" |nc localhost 56789'
  [ ${output}="0 {}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".link bot3"; sleep 2; } | telnet localhost 2222'
  echo $output
  [[ ${output} == *" Linked to bot3"* ]]
  [[ ${output} != *"TLS: handshake successful. Secure connection established."* ]]
}

@test "Non-SSL leaf with (-)dest port connects to non-SSL hub listening on (-) all" {
skip
  echo "{unlink bot3}" |nc localhost 56789
  sleep 3
  run bash -c 'echo "{setuser bot3 botaddr localhost +3313 +3313}" |nc localhost 56789'
  [ ${output}="0 {}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".link bot3"; sleep 2; } | telnet localhost 2222'
  echo $output
  [[ ${output} == *" Linked to bot3"* ]]
  [[ ${output} != *"TLS: handshake successful. Secure connection established."* ]]
}

@test "Non-SSL leaf with (-)dest port connects to non-SSL hub listening on (-) bots" {
skip
}


@test "SSL-enabled leaf denied linking to hub on - 'user' port" {
  sleep 3
  ### Don't care about return value, in case nothing is linked
  echo "{unlink bot1}" |nc localhost 56789
  run bash -c 'echo "{setuser bot1 botaddr localhost 1112 1112}" |nc localhost 56789'
  echo $output
  [ ${output}="0 {}" ]
  run bash -c 'echo "{getuser bot1 botaddr}" |nc localhost 56789'
  echo $output
  [ ${output}="0 {localhost 1112 1112}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".chaddr bot1 localhost 1112 1112"; echo ".whois bot1"; echo ".link bot1"; sleep 2; } | telnet localhost 2222'
  echo $output
  [[ ${output} == *"ERROR linking bot1: Only users may connect at this port."* ]]
}


@test "SSL-enabled leaf denied linking to hub on + 'user' port" {
skip "Failed - allowed link"
  sleep 3
  ### Don't care about return value, in case nothing is linked
  echo "{unlink bot1}" |nc localhost 56789
  run bash -c 'echo "{setuser bot1 botaddr localhost +1112 +1112}" |nc localhost 56789'
  echo $output
  [ ${output}="0 {}" ]
  run bash -c 'echo "{getuser bot1 botaddr}" |nc localhost 56789'
  echo $output
  [ ${output}="0 {localhost +1112 +1112}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".whois bot1"; echo ".link bot1"; sleep 2; } | telnet localhost 2222'
  echo $output
  [[ ${output} == *"ERROR linking bot1: Only users may connect at this port."* ]]
}

@test "Eggdrop will not attempt link to bot marked with r flag" {
  echo "{unlink bot1}" |nc localhost 56789
  echo "{setuser bot1 botaddr localhost 1111 1111}" |nc localhost 56789
  run bash -c 'echo "{botattr bot2 -grhps}"|nc localhost 45678'
  [ ${output}="0 {-}" ]
  run bash -c 'echo "{botattr bot1 -grhps}"|nc localhost 56789'
  [ ${output}="0 {-}" ]
  run bash -c 'echo "{botattr bot1 +r}"|nc localhost 56789'
  [ ${output}="0 {r}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".link bot1"; sleep 2; } | telnet localhost 2222'
  echo $output
  [[ ${output} == *"Rejecting bot bot1"* ]]
}

@test "Bot marked with +r is not allowed to link" {
  echo "{unlink bot1}" |nc localhost 56789
  run bash -c 'echo "{botattr bot2 -grhps}"|nc localhost 45678'
  [ ${output}="0 {-}" ]
  run bash -c 'echo "{botattr bot1 -grhps}"|nc localhost 56789'
  [ ${output}="0 {-}" ]
  run bash -c 'echo "{botattr bot2 +r}"|nc localhost 45678'
  [ ${output}="0 {r}" ]
  run bash -c '{ echo "testuser1"; echo "eggdrop"; echo ".link bot1"; sleep 2; } | telnet localhost 2222'
  echo $output 
  [[ ${output} == *"Lost Bot: bot1"* ]]
}

@test "h flag auto-attempts link to hub" {
skip
  kill $(cat pid.eggdrop_botnet_linking2)
  run faketime -f '+2,5y x10,0' ./eggdrop eggdrop_botnet_linking2.conf
  [ $status -eq 0 ]
  echo "{setuser bot1 botaddr localhost 1111 1111}" |nc localhost 56789
  echo "{unlink bot1}" |nc localhost 56789
  run bash -c 'echo "{botattr bot2 -grhps}"|nc localhost 45678'
  [ ${output}="0 {-}" ]
  run bash -c 'echo "{botattr bot1 -grhps}"|nc localhost 56789'
  [ ${output}="0 {-}" ]
  run bash -c 'echo "{botattr bot1 +h}"|nc localhost 56789'
  [ ${output}="0 {h}" ]
  sleep 3
  run bash -c '{ sleep 6; echo "testuser1"; echo "eggdrop"; echo ".bots"; sleep 1; } | telnet localhost 1111'
  echo $output 
  [[ ${output} == *"Bots: bot1, bot2"* ]]
  kill $(cat pid.eggdrop_botnet_linking2)
  run ./eggdrop eggdrop_botnet_linking2.conf
  [ $status -eq 0 ]
}

@test "a flag auto-attempts if hub bot fails" {
  kill $(cat pid.eggdrop_botnet_linking2)
  run faketime -f '+2,5y x10,0' ./eggdrop eggdrop_botnet_linking2.conf
  [ $status -eq 0 ]
  echo "{setuser bot3 botaddr localhost 9999 9999}" |nc localhost 56789
  echo "{unlink bot1}" |nc localhost 56789
  run bash -c 'echo "{botattr bot2 -grahps}"|nc localhost 45678'
  [ ${output}="0 {-}" ]
  run bash -c 'echo "{botattr bot1 -grahps}"|nc localhost 56789'
  [ ${output}="0 {-}" ]
  run bash -c 'echo "{botattr bot3 +h}"|nc localhost 56789'
  [ ${output}="0 {h}" ]
  run bash -c 'echo "{botattr bot1 +a}"|nc localhost 56789'
  [ ${output}="0 {h}" ]
  sleep 3
  run bash -c '{ sleep 12; echo "testuser1"; echo "eggdrop"; echo ".bots"; sleep 1; } | telnet localhost 1111'
  echo $output
  [[ ${output} == *"Bots: bot1, bot2"* ]]
  kill $(cat pid.eggdrop_botnet_linking2)
  run ./eggdrop eggdrop_botnet_linking2.conf
  [ $status -eq 0 ]
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
