@test "Run configure with --disable-ipv6" {
  cd $TRAVIS_BUILD_DIR
  run ./configure --disable-ipv6
  [ $status -eq 0 ]
}
@test "make config" {
  cd $TRAVIS_BUILD_DIR
  run bash -c "make config"
  [ $status -eq 0 ]
}

@test "make" {
  cd $TRAVIS_BUILD_DIR
  run bash -c "make"
  [ $status -eq 0 ]
}

@test "make install" {
  cd $TRAVIS_BUILD_DIR
  run bash -c "make install DEST=$HOME/noipv6"
  [ $status -eq 0 ]
}

@test "make ssl cert (silent)" {
  cd $TRAVIS_BUILD_DIR
  run bash -c "make sslsilent DEST=$HOME/noipv6"
  echo $output
  [ $status -eq 0 ]
  [ -a $HOME/noipv6/eggdrop.key ]
  [ -a $HOME/noipv6/eggdrop.crt ]
}
