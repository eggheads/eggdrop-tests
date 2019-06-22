@test "./configure" {
  cd $TRAVIS_BUILD_DIR
  run ./configure
  [ $status -eq 0 ]
}
