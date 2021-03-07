source stdlib.sh
source bash-test.sh

secExecutable="$(which sec)"
declare KEYCHAIN
chainPass="chain-pass"

sec() {
  SEC_KEYCHAIN="$KEYCHAIN" "$secExecutable" "$@"
}

setUp() {
  KEYCHAIN="$(mktemp)"
  rm "$KEYCHAIN" || die
  security create-keychain -p 'chainPass' "$KEYCHAIN" || die
}

tearDown() {
  rm $KEYCHAIN
}

testLs() {
  export -f security
  sec get foo
}

testGet() {
  security() {
    assertEquals find-generic-password $1 &&
#    assertEquals key $2 &&
    echo "value"
  }
  export -f security
  sec get key | assertEquals "value"
}


runTests