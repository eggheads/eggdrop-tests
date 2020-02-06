@test "Eggdrop setup" {
  run cp $WORK_DIR/tests/eggdrop_tcl_server* $HOME/eggdrop
#  [ $status -eq 0 ]
  run cp $WORK_DIR/tests/cmd_accept.tcl $HOME/eggdrop
#  [ $status -eq 0 ]
  cd $HOME/eggdrop
  run ./eggdrop -m eggdrop_tcl_server.conf 3>&-
  echo $output
  [ $status -eq 0 ]
}

@test "addserver adds just a server, assigns default port" {
  echo "{addserver irc.foo.com}" |nc localhost 45678
  run bash -c 'echo "{set servers}" |nc localhost 45678'
  echo ${output} |grep -P '(?=0 {).*(?=irc.foo.com:6667)'
}

@test "addserver adds a server and port" {
  echo "{addserver irc.ferg.com 8877}" |nc localhost 45678
  run bash -c 'echo "{set servers}" |nc localhost 45678'
  echo ${output} |grep -P '(?=0 {).*(?=irc.ferg.com:8877)'
}

@test "addserver adds a server, port, and password" {
  echo "{addserver irc.moo.com 4455 mypass}" |nc localhost 45678
  run bash -c 'echo "{set servers}" |nc localhost 45678'
  echo ${output} |grep -P '(?=0 {).*(?=irc.moo.com:4455:mypass)'
}

@test "addserver adds a server and SSL port" {
  echo "{addserver irc.snell.com +7000}" |nc localhost 45678
  run bash -c 'echo "{set servers}" |nc localhost 45678'
  echo $output
  echo ${output} |grep -P '(?=0 {).*(?=irc.snell.com:\+7000)'
}

@test "addserver adds IPV6 servers" {
  echo "{addserver 2344:2344:2344::5433:5433 5555}" |nc localhost 45678
  run bash -c 'echo "{set servers}" |nc localhost 45678'
  echo $output
  echo ${output} |grep -P '(?=0 {).*(?=\[2344:2344:2344::5433:5433\]:5555)'
}

@test "addserver adds IPv4 servers" {
  echo "{addserver 1.2.3.4 4444}" |nc localhost 45678
  run bash -c 'echo "{set servers}" |nc localhost 45678'
  echo $output
  echo ${output} |grep -P '(?=0 {).*(?=1.2.3.4:4444)'
} 

@test "delserver removes first element in server list" {
  echo "{delserver irc.moo.com 4455}" |nc localhost 45678
  run bash -c 'echo "{set servers}" |nc localhost 45678'
  echo ${output} |grep -P '(?=0 {)'
  [[ ${output} != *"irc.moo.com:4455"* ]]
}

@test "delserver removes middle element in server list" {
  echo "{delserver irc.ferg.com 8877}" |nc localhost 45678
  run bash -c 'echo "{set servers}" |nc localhost 45678'
  echo ${output} |grep -P '(?=0 {)'
  [[ ${output} != *"irc.ferg.com:8877"* ]]
}

@test "delserver removes last element in server list" {
  echo "{addserver irc.last.com}" |nc localhost 45678
  echo "{delserver irc.last.com}" |nc localhost 45678
  run bash -c 'echo "{set servers}" |nc localhost 45678'
  echo ${output} |grep -P '(?=0 {)'
  [[ "${output}" != *"irc.last.com:6667" ]]
}

@test "delserver accepts IPV6 addresses" {
  echo "{delserver irc.last.com}" |nc localhost 45678
  run bash -c 'echo "{set servers}" |nc localhost 45678'
  echo ${output} |grep -P '(?=0 {)'
  [[ "${output}" != *"2344:2344:2344::5433:5433:5555" ]]
}

@test "delserver accepts IPv4 addresses" {
  echo "{delserver 1.2.3.4}" |nc localhost 45678
  run bash -c 'echo "{set servers}" |nc localhost 45678'
  echo ${output} |grep -P '(?=0 {)'
  [[ ${output} != *"1.2.3.4:6667"* ]]
}

@test "delserver with no port removes first matching entry only" {
  echo "{addserver irc.firstmatch.com 1111}" |nc localhost 45678
  echo "{addserver irc.firstmatch.com 2222}" |nc localhost 45678
  echo "{delserver irc.firstmatch.com}" |nc localhost 45678
  run bash -c 'echo "{set servers}" |nc localhost 45678'
  echo $output
  echo ${output} |grep -P '(?=0 {).*(?=irc.firstmatch.com:2222)'
  [[ ${output} != *"irc.firstmatch.com:1111"* ]]
}

@test "delserver with port removes matching host/port combo" {
  echo "{addserver irc.firstmatch.com 1111}" |nc localhost 45678
  echo "{delserver irc.firstmatch.com 2222}" |nc localhost 45678
  run bash -c 'echo "{set servers}" |nc localhost 45678'
  echo $output
  echo ${output} |grep -P '(?=0 {).*(?=irc.firstmatch.com:1111)'
  [[ ${output} != *"irc.firstmatch.com:2222"* ]]
}

@test "delserver differentiates between port and +port when matching" {
  echo "{addserver irc.port.com +1111}" |nc localhost 45678
  echo "{delserver irc.port.com 2222}" |nc localhost 45678
  run bash -c 'echo "{set servers}" |nc localhost 45678'
  echo $output
  echo ${output} |grep -P '(?=0 {).*(?=irc.firstmatch.com:1111)'
  [[ ${output} != *"irc.firstmatch.com:2222"* ]]
}

@test "Eggdrop prevents :port from being added to IPv4 address" {
  run bash -c 'echo "{addserver irc.port.com:1111}" |nc localhost 45678'
  [[ ${output} == *"Make sure the port is"* ]]
}

@test "Eggdrop dies" {
  run bash -c 'reply=$(echo {die} |nc localhost 45678); echo $reply | cut -d "{" -f2 | cut -d "}" -f1'
  [ $status -eq 0 ]
}
