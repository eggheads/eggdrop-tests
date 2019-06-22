@test "Eggdrop starts" {
  skip
  cp $TRAVIS_BUILD_DIR/eggdrop-tests/cmd_accept.tcl $HOME/eggdrop/scripts/
  cp $TRAVIS_BUILD_DIR/eggdrop-tests/testbot.conf $HOME/eggdrop/
  run bash -c "cd $HOME/eggdrop && ./eggdrop -m testbot.conf"
  [ $status -eq 0 ]
}

@test "Eggdrop runs" {
  run bash -c 'ps -aux|grep [e]ggdrop'
  [ $status -eq 0 ]
}

@test "Eggdrop has TLS support" {
  run bash -c 'echo "{status}" |nc localhost 45678'
  echo $output
  [[ "$output" == *"tls {OpenSSL"* ]]
}

@test "Eggdrop has IPv6 support" {
  run bash -c 'echo "{status}" |nc localhost 45678'
  echo $output
  [[ "$output" == *"ipv6 enabled"* ]]
}

@test "Eggdrop connects to IRC" {
  sleep 15
  run bash -c 'reply=$(echo {return -level 0 \$server} |nc localhost 45678); echo $reply | cut -d "{" -f2 | cut -d "}" -f1'
  echo $reply
  echo $output
  [[ "$output" == *"freenode.net"* ]]
  [ $status -eq 0 ]
}  

@test "Eggdrop dies" {
  run bash -c 'reply=$(echo {die} |nc localhost 45678); echo $reply | cut -d "{" -f2 | cut -d "}" -f1'
  [ $status -eq 0 ]
}
