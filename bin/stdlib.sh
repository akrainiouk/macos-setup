# Bootstrap script that provides minimal functionality
# Allowing to include other library scripts (from lib directory)
# as well as basic support for error reporting

if [[ "${STD_LIB}" == "" ]]
then
  STD_LIB="$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")/lib"
  SELF_DIR="$(dirname "$(realpath "${BASH_SOURCE[1]}")")"

  log() {
    echo "$*" 1>&2
  }

  # Prints out usage message and exits
  # The caller has to supply command artuments but the caller name is
  # derived automatically.
  usage() {
    echo "Usage: $(basename "$(callerPath)") $*"
    exit 1
  }

  # Compares semantic versions making sure <actual-version>
  # is greater or equal <expected-version>
  # Semantic version components expected to be integers separated
  # by '.' character
  ensureMinVersion() {
    (( $# == 2 )) || usage "<expected-version> <actual-version>"
    local expected actual
    expected="$(sed -e 's/\./,/g' <<< "[$1]")"
    actual="$(sed -e 's/\./,/g' <<< "[$2]")"
    jq --null-input \
       --argjson expected "$expected" \
       --argjson actual "$actual" \
      '
        if $actual >= $expected then
          null | halt_error(0)
        else
          null | halt_error(1)
        end
      '
  }

  # Prints out a call stack trace to stderr
  traceback() {
    # Hide the traceback() call itself.
    local -i start=$(( ${1:-0} + 1 ))
    local -i end=${#BASH_SOURCE[@]}
    local -i i=0
    local -i j=0
    local func file line
    for ((i=start; i < end; i++))
    do
      j=$(( i - 1 ))
      func="${FUNCNAME[$i]}"
      file="$(realpath "${BASH_SOURCE[$i]}")" || file="${BASH_SOURCE[$i]}"
      line="${BASH_LINENO[$j]}"
      log "    at ${func}(${file}:${line})"
    done
  }

  error() {
    log "ERROR: $*"
    traceback 1
    return 1
  }

  die() {
    log "ERROR: $*"
    traceback 1
    exit 1
  }

  trace() {
    log "TRACE: $*"
  }

  intercept() {
    while read line
    do
      log "INTERCEPT: $line"
      echo $line
    done
  }

  callerPath() {
    local level=$(( ${1:-0} - 1 ))
    realpath "${BASH_SOURCE[$level]}"
  }

  callerDir() {
    local level=$(( ${1:-0} - 1 ))
    dirname "$(callerPath $level)"
  }

  callerSource() {
    local level, frame, line, func, path
    level=$(( ${1:-0} - 1 ))
    frame="$(caller $level)"
    line="$(cut -d ' ' -f 1 <<< "$frame")"
    func="$(cut -d ' ' -f 2 <<< "$frame")"
    path="$(sed -e 's/[^ ]* [^ ]* //g' <<< $frame)"
    echo "  at $func($path:$line)"
  }

  # Include (source) bash script from standard lib location
  include_std() {
    (( $# == 1 )) || error "Missing argument: <file-name>"
    local includeFile="$STD_LIB/$1"
    source "$includeFile"
  }

  # Include (source) bash script with path relative to calling script itsef.
  include() {
    (( $# == 1 )) || error "Missing argument: <file-name>"
    local includeFile
    includeFile="$(callerDir 1)/$1"
    if [[ -f "$includeFile" ]]
    then
      source "$includeFile"
    else
      error "File not found '$includeFile'"
    fi
  }

  # Runs specified script resolving its name relative to the caller path
  run() {
    (( $# >= 1 )) || error "Missing argument(s): <script> [ <args>... ]"
    local script
    script="$(callerDir 1)/$1"
    shift
    $script "$@"
  }

  if [ "${BASH_VERSINFO:-0}" -lt 5 ]
  then
    log "ERROR: Insufficient bash version in $(basename "$0"): [$BASH_VERSION]. Version >= 5 required."
    log "       MacOs hint: consider using [#!/usr/bin/env bash] instead of [#!/bin/bash]"
    traceback 1
    exit 1
  fi

fi

