
assertEquals() {
  (( $# > 0 )) || die "Usage assertEquals <expected> [ <actual> ]"
  local expected="$1" actual
  if (( $# == 1 ))
  then
    actual="$(cat)"
  elif (( $# == 2 ))
  then
    actual="$2"
  fi
  if [[ "$expected" != "$actual" ]]
  then
    echo "Assertion failed. Expected: [$expected] but was [$actual]" 2>&1
    traceback 1
    return 1
  fi
}

runTests() {
  local tests
  tests="$(declare -F | cut -d ' ' -f 3 | grep '^test.*')"
  for test in $tests
  do
    echo "Running: [$test]..."
    if "$test"
    then
      echo "Succeeded: [$test]"
    else
      echo "Failed with code $?: [$test]"
    fi
  done
}

export -f assertEquals
