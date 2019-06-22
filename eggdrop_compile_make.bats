@test "make config" {
  cd $TRAVIS_BUILD_DIR
  chown -R eggdrop:eggdrop *
  chown -R eggdrop:eggdrop .*
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
  run bash -c "make install"
  [ $status -eq 0 ]
}

