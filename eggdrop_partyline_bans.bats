@test "Eggdrop setup" {
  run cp $WORK_DIR/tests/eggdrop_partyline_bans* $HOME/eggdrop/
  [ $status -eq 0 ]
  run cp $WORK_DIR/tests/cmd_accept.tcl $HOME/eggdrop/scripts/
  [ $status -eq 0 ]
  run ./eggdrop eggdrop_partyline_bans.conf
  [ $status -eq 0 ]
  echo "{channel add #foober}" |nc localhost 45678
}


@test "Eggdrop accepts bans with no time expiration" {
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo 'testuser1'; echo "$PASS"; echo '.+ban *!*@foo.com'; echo '.bans *!*@foo.com'; sleep 2; } | telnet localhost 1111"
#  echo "# ${output}" >&3
  [[ ${output} == *'*!*@foo.com (perm)'* ]]
}

@test "Eggdrop accepts bans with tiny time expirations" {
  echo '{killban *\!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo 'testuser1'; echo "$PASS"; echo '.+ban *!*@foo.com %1m'; echo '.bans *!*@foo.com'; sleep 2; } | telnet localhost 1111"
  echo $output
  [[ ${output} == *'*!*@foo.com (expires at'* ]]
}

@test "Eggdrop accepts bans with large time expirations" {
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo 'testuser1'; echo "$PASS"; echo '.+ban *!*@foo.com %720d1h1m'; echo '.bans *!*@foo.com'; sleep 2; } | telnet localhost 1111"
  echo $output
  [[ ${output} == *'*!*@foo.com (expires in 720 days)'* ]]
}

@test "Eggdrop accepts bans <=1825 days" {
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo ;testuser1'; echo $PASS; echo '.+ban *!*@foo.com %1825d'; sleep 2; } |telnet localhost 1111"
  [[ ${output} == *'*!*@foo.com (expires in 1825 days)'* ]]
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo ;testuser1'; echo $PASS; echo '.+ban *!*@foo.com %1824d'; sleep 2; } |telnet localhost 1111"
  [[ ${output} == *'*!*@foo.com (expires in 1824 days)'* ]]
}


@test "Eggdrop rejects bans greater than 1825 years via multiple hour/day/month/year inputs" {
  echo '{killban *!*@foo.com}' |nc localhost 45678 
  run bash -c "{ echo ;testuser1'; echo $PASS; echo '.+ban *!*@foo.com %6y'; sleep 2; } |telnet localhost 1111"
  [[ ${output} == *'Ban expiration time cannot exceed 5 years (1825 days)'* ]]
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo ;testuser1'; echo $PASS; echo '.+ban *!*@foo.com %1826d'; sleep 2; } |telnet localhost 1111"
  [[ ${output} == *'Ban expiration time cannot exceed 5 years (1825 days)'* ]]
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo ;testuser1'; echo $PASS; echo '.+ban *!*@foo.com %1824d25h'; sleep 2; } |telnet localhost 1111"
  [[ ${output} == *'Ban expiration time cannot exceed 5 years (1825 days)'* ]]
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo ;testuser1'; echo $PASS; echo '.+ban *!*@foo.com %43801h'; sleep 2; } |telnet localhost 1111"
  [[ ${output} == *'Ban expiration time cannot exceed 5 years (1825 days)'* ]]
  echo '{killban *!*@foo.com}' |nc localhost 45678 
  run bash -c "{ echo ;testuser1'; echo $PASS; echo '.+ban *!*@foo.com %2628001m'; sleep 2; } |telnet localhost 1111"
  [[ ${output} == *'Ban expiration time cannot exceed 5 years (1825 days)'* ]]
}


@test "Eggdrop accepts bans with a channel option set" {
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo 'testuser1'; echo "$PASS"; echo '.+ban *!*@foo.com #foober'; echo '.bans *!*@foo.com'; sleep 2; } | telnet localhost 1111"
  echo $output
  [[ ${output} == *'Channel bans for #foober:'*'*!*@foo.com (perm)'* ]]
}


@test "Eggdrop accepts bans prefixed with * to make it sticky" {
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo 'testuser1'; echo "$PASS"; echo '.+ban *!*@foo.com *stickyban'; echo '.bans *!*@foo.com'; sleep 2; } | telnet localhost 1111"
  echo $output
  [[ ${output} == *'*!*@foo.com (perm) (sticky)'* ]]
}

@test "Eggdrop accepts bans with time and comment, but no channel" {
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo 'testuser1'; echo "$PASS"; echo '.+ban *!*@foo.com %30d1h1m This is a comment'; echo '.bans *!*@foo.com'; sleep 2; } | telnet localhost 1111"
  echo $output
  [[ ${output} == *'*!*@foo.com (expires in 30 days)'* ]]
  [[ ${output} == *': This is a comment'* ]]
}

@test "Eggdrop accepts bans with channel and comment, but no time" {
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo 'testuser1'; echo "$PASS"; echo '.+ban *!*@foo.com #foober This is a comment'; echo '.bans *!*@foo.com'; sleep 2; } | telnet localhost 1111"
  echo $output
  [[ ${output} == *'New #foober ban: *!*@foo.com'* ]]
  [[ ${output} == *': This is a comment'* ]]
}

@test "Eggdrop accepts bans with channel and time, but no comment" {
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo 'testuser1'; echo "$PASS"; echo '.+ban *!*@foo.com #foober %30d1h1m This is a comment'; echo '.bans *!*@foo.com'; sleep 2; } | telnet localhost 1111"
  echo $output
  [[ ${output} == *'New #foober ban: *!*@foo.com'* ]]
  [[ ${output} == *'*!*@foo.com (expires in 30 days)'* ]]
}

@test "Eggdrop rejects channel ban for non-added channel" {
  echo '{killban *!*@foo.com}' |nc localhost 45678
  run bash -c "{ echo 'testuser1'; echo "$PASS"; echo '.+ban *!*@foo.com #notachan'; sleep 2; } | telnet localhost 1111"
  echo $output
  [[ ${output} == *"That channel doesn't exist!"* ]]
 ### Should check the ban list here too, but how...
}

@test "Eggdrop dies" {
  run bash -c 'reply=$(echo {die} |nc localhost 45678); echo $reply | cut -d "{" -f2 | cut -d "}" -f1'
  [ $status -eq 0 ]
}

