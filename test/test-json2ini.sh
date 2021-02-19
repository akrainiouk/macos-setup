#!/usr/bin/env bash

source stdlib.sh
include ../bin/bash-test.sh

toJson() {
  yq --tojson eval "." - <<< "$1"
}

lines() {
  for arg in "$@"
  do
    echo $arg
  done
}

testEmptySections() {
  local input expected actual
  input="$(toJson '{ section1: {}, section2: {}}')"
  expected="$(lines "[section1]" "[section2]")"
  actual="$(json2ini.jq <<< "$input")"
  assertEquals "$expected" "$actual"
}

testMultipleKeys() {
  local input expected actual
  input="$(toJson '{ section: { key1: value1, key2: value2 }}')"
  expected="$(lines "[section]" "key1 = value1" "key2 = value2")"
  actual="$(json2ini.jq <<< "$input")"
  assertEquals "$expected" "$actual"
}

runTests
