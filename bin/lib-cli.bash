#!/usr/bin/env bash
# Experimantal!
# Parses command line separating options from the other arguments
# Optiona are expected to be in the form
# --<option-name>=<option-value>
# parsed options are stored in the the hashmap named OPTS and arguments
# are stored in an array named ARGS
# original arguments are consumed completely
#
# Usage:
#   source lib-std.bash
#
# Shortcomings:
# - it is not possible to parse parameters of a nested function call
# - relies on global variables with hard coded names
#
# Future plans:
#   Proper implementation should probably just store parsed arguments into JSON
#   It can also take JSON specification of supported command line arguments
#

if [[ ! -v STD_LIB ]]
then
  source lib-std.bash
  die "[source lib-std.bash] is required"
fi

optName() {
  sed -Ee 's/^--([^=]+).*/\1/g' <<< "$1"
}

optValue() {
  if ! grep -q '=' <<< "$1"; then
    echo ""
  else
    sed -Ee 's/^[^=]+=//g' <<< "$1"
  fi
}

declare -A OPTS
declare -a ARGS

[[ ! -v ARGS ]] || die "ARGS variable already exists"
[[ ! -v OPTS ]] || die "OPTS variable already exists"
export -a ARGS=()
while (( $# > 0 ))
do
  case "$1" in
  --*) name="$(optName "$1")"
       val="$(optValue "$1")"
       OPTS+=( ["$name"]="$val" )
       ;;
  -*)  reject "Short options are not supported: '$1'";;
  *)   ARGS+=( "$1" );;
  esac
  shift
done

declare -r OPTS ARGS
unset optName
unset optValue