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

@test "make ssl cert (silent)" {
  cd $TRAVIS_BUILD_DIR
  run bash -c "make sslsilent"
  echo $output
  [ $status -eq 0 ]
  [ -a eggdrop.key ]
  [ -a eggdrop.crt ]
}

@test "make install" {
  cd $TRAVIS_BUILD_DIR
  run bash -c "make install"
  [ $status -eq 0 ]
}

