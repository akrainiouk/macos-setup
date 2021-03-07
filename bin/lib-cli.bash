#!/usr/bin/env bash

if [[ ! -v STD_LIB ]]
then
  source lib-std.bash
  die "[source lib-std.bash] is required"
fi

optName() {
  sed -Ee 's/^--([^=]+).*/\1/g' <<< "$1"
}

optValue() {
  sed -Ee 's/^[^=]+=//g' <<< "$1"
}

assertArray() {
  declare -p "$1" | grep -q 'declare \-a' || die "$1 is not an array"
}

assertAssocArray() {
  declare -p "$1" | grep -q 'declare \-A' || die "$1 is not an associative array"
}

parseCommandLine() {
  declare -n argsVar="$1"
  declare -n optsVar="$2"
  assertArray "$1"
  assertAssocArray "$2"
  shift 2
  while (( $# > 0 ))
  do
    case "$1" in
    --*) optsVar["$(optName "$1")"]="$(optValue "$1")";;
    *)   argsVar+=( "$1" );;
    esac
    shift
  done
}

toOpts() {
  declare -n optsVar="$1"
  declare -n cmdLineVar="$2"
  assertAssocArray "$1"
  assertArray "$2"
  for key in "${!optsVar[@]}"
  do
    cmdLine+=( "--$key=${optsVar["$key"]}" )
  done
}
