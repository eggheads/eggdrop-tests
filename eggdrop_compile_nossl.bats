@test "Run configure with --disable-tls" {
  cd $TRAVIS_BUILD_DIR
  run ./configure --disable-tls
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
  run bash -c "make install DEST=$HOME/nossl"
  [ $status -eq 0 ]
}
