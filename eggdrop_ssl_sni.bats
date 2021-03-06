teardown() {
  ps x|grep "[e]ggdrop "
  if [ $? -eq 0 ]; then
    pkill eggdrop
  fi
  if [ -e $HOME/eggdrop/tempuser.user ]; then
    rm $HOME/eggdrop/tempsuer.user
  fi
}


@test "Eggdrop setup" {
  run cp $WORK_DIR/tests/eggdrop_ssl_sni.* .
  [ $status -eq 0 ]
  run cp $WORK_DIR/tests/cmd_accept.tcl .
  [ $status -eq 0 ]
}

@test "Eggdrop uses SNI" {
  run ./eggdrop -nt eggdrop_ssl_sni.conf
  echo $output |grep "TLS: certificate subject: CN=irc.darenet.org"
  sed -i '/set server/c\set servers {skylab.darenet.org:+6697}' eggdrop_ssl_sni.conf
  run ./eggdrop -nt eggdrop_ssl_sni.conf
  echo $output |grep "TLS: certificate subject: CN=skylab.darenet.org"
}
