@test "Eggdrop setup" {
  run cp $WORK_DIR/tests/eggdrop_chanset_inputvalidation* $HOME/eggdrop/
  [ $status -eq 0 ]
  run cp $WORK_DIR/tests/cmd_accept.tcl $HOME/eggdrop/scripts/
  [ $status -eq 0 ]
  cd $HOME
  run ./eggdrop -m eggdrop_chanset_inputvalidation.conf 3>&-
  echo $output
  [ $status -eq 0 ]
  echo {channel add \#eggtest} |nc localhost 45678
}

@test "Flood* accepts valid inputs" {
# Accepts X:X input
  echo {channel set \#eggtest flood-deop 253:42} |nc localhost 45678
  run bash -c 'echo "{channel info #eggtest}" |nc localhost 45678' 
  [[ $output == *"253:42"* ]]
}

@test "Flood* settings prevent non-integer input" {
# Denies X:D, D:X inputs
  run bash -c 'echo {channel set \#eggtest flood-deop 4:D} |nc localhost 45678'
  [[ $output == *"values must be integers"* ]]
  run bash -c 'echo {channel set \#eggtest flood-deop 2a:4} |nc localhost 45678'
  [[ $output == *"values must be integers >= 0"* ]]
  run bash -c 'echo {channel set \#eggtest flood-deop 2:4a} |nc localhost 45678'
  [[ $output == *"values must be integers >= 0"* ]]
}

@test "Flood* settings prevent single (non-zero) entry" {
# Denies just '4' as input
  run bash -c 'echo {channel set \#eggtest flood-deop 4} |nc localhost 45678'
  [[ $output == *"flood value must be in X:Y format"* ]]
}

@test "Flood* settings prevent invalid input format" {
# Denies entries like ':X' 'X:' '3:4:5', '3a:4'
  run bash -c 'echo {channel set \#eggtest flood-deop :3} |nc localhost 45678'
  [[ $output == *"flood value must be in X:Y format"* ]]
  run bash -c 'echo {channel set \#eggtest flood-deop 3:} |nc localhost 45678'
  [[ $output == *"flood value must be in X:Y format"* ]]
  run bash -c 'echo {channel set \#eggtest flood-deop 53:75:86} |nc localhost 45678'
  [[ $output == *"flood value must be in X:Y format"* ]]
}

@test "Flood* settings prevent negative numbers" {
  run bash -c 'echo {channel set \#eggtest flood-deop -1:8} |nc localhost 45678'
  [[ $output == *"values must be integers >= 0"* ]]
}

@test "Flood* set to 0 clears flood setting" {
# 0, 0:0, 4:0, 0:4
  echo {channel set \#eggtest flood-deop 6:9} |nc localhost 45678
  bash -c 'echo {channel set \#eggtest flood-deop 0} |nc localhost 45678'
  run bash -c 'echo {channel info \#eggtest} |nc localhost 45678'
  FOO=$(echo $output| cut -d " " -f 15)
  [ $FOO == "0:0" ]

  echo {channel set \#eggtest flood-deop 6:9} |nc localhost 45678
  bash -c 'echo {channel set \#eggtest flood-deop 0:0} |nc localhost 45678'
  run bash -c 'echo {channel info \#eggtest} |nc localhost 45678'
  FOO=$(echo $output| cut -d " " -f 15)
  [ $FOO == "0:0" ]

  echo {channel set \#eggtest flood-deop 6:9} |nc localhost 45678
  bash -c 'echo {channel set \#eggtest flood-deop 9:0} |nc localhost 45678'
  run bash -c 'echo {channel info \#eggtest} |nc localhost 45678'
  FOO=$(echo $output| cut -d " " -f 15)
  [ $FOO == "9:0" ]

  echo {channel set \#eggtest flood-deop 6:9} |nc localhost 45678
  bash -c 'echo {channel set \#eggtest flood-deop 0:8} |nc localhost 45678'
  run bash -c 'echo {channel info \#eggtest} |nc localhost 45678'
  FOO=$(echo $output| cut -d " " -f 15)
  [ $FOO == "0:8" ]
}
