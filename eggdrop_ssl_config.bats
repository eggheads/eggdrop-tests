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
  run cp $WORK_DIR/tests/eggdrop_ssl_config.* $HOME/eggdrop
  [ $status -eq 0 ]
  run cp $WORK_DIR/tests/cmd_accept.tcl $HOME/eggdrop
  [ $status -eq 0 ]
#  run cp $WORK_DIR/tests/eggdrop.{key,crt} $HOME/eggdrop
#  [ $status -eq 0 ]
  cp $HOME/eggdrop/eggdrop.key $HOME/eggdrop/eggdropz.key
  cp $HOME/eggdrop/eggdrop.crt $HOME/eggdrop/eggdropz.crt
  cd $HOME/eggdrop
}


@test "Eggdrop runs/uses proper SSL keys" {
skip
  cd $HOME/eggdrop
  sed -i '/set ssl-certificate/c\set ssl-certificate \"eggdropz.crt\"' $HOME/eggdrop/eggdrop_ssl_config.conf
  sed -i '/set ssl-privatekey/c\set ssl-privatekey \"eggdropz.key\"' $HOME/eggdrop/eggdrop_ssl_config.conf
  run ./eggdrop eggdrop_ssl_config.conf
  [ $status -eq 0 ]
## Check values of running bot...
}


@test "Eggdrop dies if user-specified .key file is missing/incorrect" {
  cd $HOME/eggdrop
  sed -i '/set ssl-certificate/c\set ssl-certificate \"eggdrop.crt\"' $HOME/eggdrop/eggdrop_ssl_config.conf
  sed -i '/set ssl-privatekey/c\set ssl-privatekey \"sdfsdf.key\"' $HOME/eggdrop/eggdrop_ssl_config.conf
  run ./eggdrop eggdrop_ssl_config.conf
  echo $output
  [[ "$output" == *"Unable to load TLS private key (ssl-privatekey config setting)"* ]]
  [ $status -eq 1 ]
}


@test "Eggdrop dies if user-specified .crt file is missing/incorrect" {
  cd $HOME/eggdrop
  sed -i '/set ssl-certificate/c\set ssl-certificate \"sdfsdf.crt\"' $HOME/eggdrop/eggdrop_ssl_config.conf
  sed -i '/set ssl-privatekey/c\set ssl-privatekey \"eggdrop.key\"' $HOME/eggdrop/eggdrop_ssl_config.conf
  run ./eggdrop eggdrop_ssl_config.conf
  [[ "$output" == *"Unable to load TLS certificate (ssl-certificate config setting"* ]]
  [ $status -eq 1 ]
}


@test "Eggdrop runs if SSL .key and .crt file are commented" {
  cd $HOME/eggdrop
  sed -i '/set ssl-certificate/c\#set ssl-certificate \"eggdrop.crt\"' $HOME/eggdrop/eggdrop_ssl_config.conf
  sed -i '/set ssl-privatekey/c\#set ssl-privatekey \"eggdrop.key\"' $HOME/eggdrop/eggdrop_ssl_config.conf
  run ./eggdrop eggdrop_ssl_config.conf
  [ $status -eq 0 ]
}


@test "Eggdrop runs if SSL .key and .crt file are set to \"\"" {
  cd $HOME/eggdrop
  sed -i '/set ssl-certificate/c\set ssl-certificate \"\"' $HOME/eggdrop/eggdrop_ssl_config.conf
  sed -i '/set ssl-privatekey/c\set ssl-privatekey \"\"' $HOME/eggdrop/eggdrop_ssl_config.conf
  run ./eggdrop eggdrop_ssl_config.conf
  [ $status -eq 0 ]
}


@test "Eggdrop dies if .crt is specified/present, but .key is commented" {
  cd $HOME/eggdrop
  sed -i '/set ssl-certificate/c\set ssl-certificate \"eggdrop.crt\"' $HOME/eggdrop/eggdrop_ssl_config.conf
  sed -i '/set ssl-privatekey/c\#set ssl-privatekey \"\"' $HOME/eggdrop/eggdrop_ssl_config.conf
  run ./eggdrop eggdrop_ssl_config.conf 2>&1
  [[ "$output" == *"ERROR: TLS: ssl-certificate set but ssl-privatekey unset. Both must be set to use a certificate, or unset both to disable."* ]]
  [ $status -eq 1 ]
}


@test "Eggdrop dies if .key is specified/present, but .crt is commented" {
  cd $HOME/eggdrop
  sed -i '/set ssl-certificate/c\#set ssl-certificate \"\"' $HOME/eggdrop/eggdrop_ssl_config.conf
  sed -i '/set ssl-privatekey/c\set ssl-privatekey \"eggdrop.key\"' $HOME/eggdrop/eggdrop_ssl_config.conf
  run ./eggdrop eggdrop_ssl_config.conf 2>&1
  echo $output
  [[ "$output" == *"ERROR: TLS: ssl-privatekey set but ssl-certificate unset. Both must be set to use a certificate, or unset both to disable."* ]]
  [ $status -eq 1 ]
}

@test "Eggdrop dies if key file empty" {
  cd $HOME/eggdrop
  touch badkey.key
  sed -i '/set ssl-privatekey/c\set ssl-privatekey \"badkey.key\"' $HOME/eggdrop/eggdrop_ssl_config.conf
  sed -i '/set ssl-certificate/c\set ssl-certificate \"eggdrop.crt\"' $HOME/eggdrop/eggdrop_ssl_config.conf
  run ./eggdrop eggdrop_ssl_config.conf
  rm badkey.key
  [[ ${output} == *"ERROR: TLS: unable to load private key from badkey.key: error:"* ]]
  [ $status -eq 1 ]
}

@test "Eggdrop dies if key/crt file do not match" {
  cd $HOME/eggdrop
  sed -i '/set ssl-privatekey/c\set ssl-privatekey \"eggdrop_ssl_config.badpair.key\"' $HOME/eggdrop/eggdrop_ssl_config.conf
  sed -i '/set ssl-certificate/c\set ssl-certificate \"eggdrop.crt\"' $HOME/eggdrop/eggdrop_ssl_config.conf
  run ./eggdrop eggdrop_ssl_config.conf
  echo $output
  [[ ${output} == *"ERROR: TLS: unable to load private key from eggdrop_ssl_config.badpair.key: error:0B080074:x509 certificate routines:X509_check_private_key:key values mismatch"* ]]
  [ $status -eq 1 ]
}

@test "Eggdrop disconnects on no matching protocols" {
  cd $HOME/eggdrop
  sed -i '/set ssl-protocols/c\set ssl-protocols "GEO"' $HOME/eggdrop/eggdrop_ssl_config.conf
  sed -i '/set ssl-privatekey/c\set ssl-privatekey \"eggdrop.key\"' $HOME/eggdrop/eggdrop_ssl_config.conf
  run ./eggdrop -nt eggdrop_ssl_config.conf
  ssltext=${output}
  echo ${ssltext}
  echo ${ssltext}|grep "tls_construct_client_hello:no protocols available";
  [ $status -eq 0 ]
}

@test "Eggdrop chooses proper SSL/TLS protocol, Eggdrop higher than server" {
# Freenode offers 1.0 and 1.2
  cd $HOME/eggdrop
  sed -i '/set ssl-protocols/c\set ssl-protocols "TLSv1 TLSv1.1 TLSv1.2 TLSv1.3"' $HOME/eggdrop/eggdrop_ssl_config.conf
  run ./eggdrop -nt eggdrop_ssl_config.conf
  ssltext=${output}
  echo ${ssltext}
  echo ${ssltext}|grep "TLS: cipher used:"|grep TLSv1.2;
  [ $status -eq 0 ]
}

@test "Eggdrop chooses proper SSL/TLS protocol, Eggdrop same as server" {
  cd $HOME/eggdrop
  sed -i '/set ssl-protocols/c\set ssl-protocols "TLSv1 TLSv1.1 TLSv1.2"' $HOME/eggdrop/eggdrop_ssl_config.conf
  run ./eggdrop -nt eggdrop_ssl_config.conf
  ssltext=${output}
  echo ${ssltext}|grep "TLS: cipher used:"| grep TLSv1.2;
  [ $status -eq 0 ]
}

@test "Eggdrop chooses proper SSL/TLS protocol, Eggdrop lower than server" {
  cd $HOME/eggdrop
  sed -i '/set ssl-protocols/c\set ssl-protocols "TLSv1 TLSv1.1"' $HOME/eggdrop/eggdrop_ssl_config.conf
  run ./eggdrop -nt eggdrop_ssl_config.conf
  ssltext=${output}
  echo ${ssltext}|grep "TLS: cipher used:"| grep TLSv1.1;
  echo $output
  [ $status -eq 0 ]
}

@test "Eggdrop uses specified SSL/TLS cipher" {
  cd $HOME/eggdrop
  sed -i '/set ssl-ciphers/c\set ssl-ciphers "ECDHE-RSA-AES256-SHA"' $HOME/eggdrop/eggdrop_ssl_config.conf
  run ./eggdrop -nt eggdrop_ssl_config.conf
  ssltext=${output}
  echo ${ssltext}|grep "TLS: cipher used: ECDHE-RSA-AES256-SHA"
  [ $status -eq 0 ]
}

@test "Eggdrop disconnects on required cipher stronger than supported protocol" {
  cd $HOME/eggdrop
  sed -i '/set ssl-protocols/c\set ssl-protocols "TLSv1"' $HOME/eggdrop/eggdrop_ssl_config.conf
  sed -i '/set ssl-ciphers/c\set ssl-ciphers "ECDHE-RSA-AES256-GCM-SHA384"' $HOME/eggdrop/eggdrop_ssl_config.conf
  run ./eggdrop -nt eggdrop_ssl_config.conf
  ssltext=${output}
  echo $output
  echo ${ssltext}|grep "SSL routines:ssl_cipher_list_to_bytes:no ciphers available"
}

@test "Eggdrop disconnects on required cipher weaker/disallowed by supported protocol" {
  cd $HOME/eggdrop
  sed -i '/set ssl-protocols/c\set ssl-protocols "TLSv1.2"' $HOME/eggdrop/eggdrop_ssl_config.conf
  sed -i '/set ssl-ciphers/c\set ssl-ciphers "TLS_RSA_WITH_AES_128_CBC_SHA"' $HOME/eggdrop/eggdrop_ssl_config.conf
  run ./eggdrop -nt eggdrop_ssl_config.conf
  ssltext=${output}
  echo $output
  echo ${ssltext}|grep "SSL routines:ssl_cipher_list_to_bytes:no ciphers available"
}


@test "Eggdrop warns on incorrect DHParam file" {
  cd $HOME/eggdrop
  sed -i '/set ssl-protocols/c\set ssl-ciphers "DEFAULT"' $HOME/eggdrop/eggdrop_ssl_config.conf
  sed -i '/set ssl-dhparam/c\set ssl-dhparam "foo.pem"' $HOME/eggdrop/eggdrop_ssl_config.conf
  run ./eggdrop -nt eggdrop_ssl_config.conf
  ssltext=${output}
  echo ${output}
  echo ${ssltext} |grep "ERROR: TLS: unable to open foo.pem: No such file or directory"
}
