@test "Eggdrop setup" {
  run cp /tmp/build/tests/eggdrop_partyline_bans* /home/eggdrop/eggdrop/
  [ $status -eq 0 ]
  run cp /tmp/build/tests/cmd_accept.tcl /home/eggdrop/eggdrop/scripts/
  [ $status -eq 0 ]
  run ./eggdrop eggdrop_partyline_bans.conf
  [ $status -eq 0 ]
  echo "{channel add #foober}" |nc localhost 45678
}


@test "Eggdrop accepts bans with no time expiration" {
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo 'testuser1'; echo 'eggdrop'; echo '.+ban *!*@foo.com'; echo '.bans *!*@foo.com'; sleep 2; } | telnet localhost 1111"
#  echo "# ${output}" >&3
  [[ ${output} == *'*!*@foo.com (perm)'* ]]
}

@test "Eggdrop accepts bans with tiny time expirations" {
  echo '{killban *\!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo 'testuser1'; echo 'eggdrop'; echo '.+ban *!*@foo.com %1m'; echo '.bans *!*@foo.com'; sleep 2; } | telnet localhost 1111"
  echo $output
  [[ ${output} == *'*!*@foo.com (expires at'* ]]
}

@test "Eggdrop accepts bans with large time expirations" {
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo 'testuser1'; echo 'eggdrop'; echo '.+ban *!*@foo.com %720d1h1m'; echo '.bans *!*@foo.com'; sleep 2; } | telnet localhost 1111"
  echo $output
  [[ ${output} == *'*!*@foo.com (expires in 720 days)'* ]]
}

@test "Eggdrop rejects bans with over ~19 years time expirations" {
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo 'testuser1'; echo 'eggdrop'; echo '.+ban *!*@foo.com %72000d1h1m'; echo '.bans *!*@foo.com'; sleep 2; } | telnet localhost 1111"
  echo $output
  [[ ${output} == *'*!*@foo.com (expires in 7088 days)'* ]]
}

@test "Eggdrop accepts bans with a channel option set" {
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo 'testuser1'; echo 'eggdrop'; echo '.+ban *!*@foo.com #foober'; echo '.bans *!*@foo.com'; sleep 2; } | telnet localhost 1111"
  echo $output
  [[ ${output} == *'Channel bans for #foober:'*'*!*@foo.com (perm)'* ]]
}


@test "Eggdrop accepts bans prefixed with * to make it sticky" {
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo 'testuser1'; echo 'eggdrop'; echo '.+ban *!*@foo.com *stickyban'; echo '.bans *!*@foo.com'; sleep 2; } | telnet localhost 1111"
  echo $output
  [[ ${output} == *'*!*@foo.com (perm) (sticky)'* ]]
}

@test "Eggdrop accepts bans with time and comment, but no channel" {
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo 'testuser1'; echo 'eggdrop'; echo '.+ban *!*@foo.com %30d1h1m This is a comment'; echo '.bans *!*@foo.com'; sleep 2; } | telnet localhost 1111"
  echo $output
  [[ ${output} == *'*!*@foo.com (expires in 30 days)'* ]]
  [[ ${output} == *': This is a comment'* ]]
}

@test "Eggdrop accepts bans with channel and comment, but no time" {
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo 'testuser1'; echo 'eggdrop'; echo '.+ban *!*@foo.com #foober This is a comment'; echo '.bans *!*@foo.com'; sleep 2; } | telnet localhost 1111"
  echo $output
  [[ ${output} == *'New #foober ban: *!*@foo.com'* ]]
  [[ ${output} == *': This is a comment'* ]]
}

@test "Eggdrop accepts bans with channel and time, but no comment" {
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo 'testuser1'; echo 'eggdrop'; echo '.+ban *!*@foo.com #foober %30d1h1m This is a comment'; echo '.bans *!*@foo.com'; sleep 2; } | telnet localhost 1111"
  echo $output
  [[ ${output} == *'New #foober ban: *!*@foo.com'* ]]
  [[ ${output} == *'*!*@foo.com (expires in 30 days)'* ]]
}

@test "Eggdrop rejects channel ban for non-added channel" {
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo 'testuser1'; echo 'eggdrop'; echo '.+ban *!*@foo.com #notachan'; sleep 2; } | telnet localhost 1111"
  echo $output
  [[ ${output} == *"That channel doesn't exist!"* ]]
 ### Should check the ban list here too, but how...
}

@test "Eggdrop dies" {
  run bash -c 'reply=$(echo {die} |nc localhost 45678); echo $reply | cut -d "{" -f2 | cut -d "}" -f1'
  [ $status -eq 0 ]
}

