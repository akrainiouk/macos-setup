# Bootstrap script that provides minimal functionality
# Allowing to include other library scripts (from lib directory)
# as well as basic support for error reporting

if [[ "${LIB_STD}" == "" ]]
then
  declare -r LIB_STD="$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")/lib"

  # Error codes

  # REJECTED - precondition failed. Assumes user friendly error message and no stack trace.
  REJECTED=254
  # ASSERTION - internal check failed. Stack trace will be automatically produced.
  ASSERTION_FAILED=253

  warn() {
    for line in "$@"
    do
      echo "$line" 1>&2
    done
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

  isRemoteShell() {
    [[ "$(who am i )" =~ \([-a-zA-Z0-9\.:]+\)$ ]]
  }

  # Prints out caller source reference formatted in such a way
  # that frames can be navigated in Intellij IDEA
  # Usage: callerSource [ <level> ]
  callerSource() {
    local -i level
    local frame line func path
    level=$(( ${1:-1} ))
    func="${FUNCNAME[$level]}"
    file="$(realpath "${BASH_SOURCE[$level]}")" || file="${BASH_SOURCE[$level]}"
    line="${BASH_LINENO[(( $level - 1 ))]}"
    echo "    at $func($file:$line)"
  }

  # Prints out a call stack trace to stderr
  traceback() {
    echo "Call stack:"
    # Hide the traceback() call itself.
    local -i start=$(( ${1:-0} + 1 ))
    local -i end=${#BASH_SOURCE[@]}
    local -i i=0
    for ((i=start; i < end; i++))
    do
      callerSource $(( i + 1 ))
    done
  }

  error() {
    print_error "$@"
    warn "$(traceback 1)"
    return 1
  }

  print_error() {
    local firstLine="ERROR: $1"
    shift
    warn "$firstLine" "$@"
  }

  ## Dies printing supplied error messages but without
  ## dumping stack trace
  ## Usage reject "Failed for some reason"
  reject() {
    (( $# >= 1 )) || die "invalid arguments. Expected <error-message> [ <error-message>... ]"
    print_error "$@"
    exit "$REJECTED"
  }

  ## Dies printing supplied error message followed
  ## by the stack trace
  ## Usage: die "Failed for some reason" "more info"...
  die() {
    if (( $# > 0 ))
    then
      print_error "$@"
    fi
    warn "$(traceback 1)"
    exit $ASSERTION_FAILED
  }

  trace() {
    for line in "$@"
    do
      warn "TRACE: $line"
    done
  }

  # Pipes its stdin into stdout intercepting each line
  # and logging it into stderr with "INTERCEPT: " prefix.
  intercept() {
    while read line
    do
      warn "INTERCEPT: $line"
      echo $line
    done
  }

  # Prints out caller script path
  # Usage: callerPath [ <level> ]
  callerPath() {
    local level=$(( ${1:-0} + 1 ))
    (( ${#BASH_SOURCE[@]} > $level )) || die "Requested level exceeds actual caller nesting level"
    realpath "${BASH_SOURCE[$level]}"
  }

  # Prints out caller script directory
  # Usage: callerDir [ <level> ]
  callerDir() {
    local level=$(( ${1:-0} + 1 ))
    dirname "$(callerPath $level)"
  }

  ## Resolve specified path against caller script directory
  ## If specified path is an absolute path it is kep intact (but canonicalized)
  ## If specified path is relative path it gets resolved against caller directory
  ## Usage: resolveFile [ <level> ] <path>
  resolveFile() {
    local level=1
    (( $# <  2 )) || { level=$(( $1 + 1 )); shift; }
    (( $# == 1 )) || die "Insufficient arguments. Expected [ <path> ]"
    file="$1"
    case "$file" in
    /*) realpath "$file";;
    *)  realpath "$(callerDir 1)/$file";;
    esac
  }

  # Prints out usage message and exits
  # The caller has to supply command arguments but the caller name is
  # derived automatically.
  # Usage:
  # usage <arg-list> [ <comment-line>... ]
  usage() {
    (( $# >= 1 )) || die "Missing argument <arg-list>"
    local arglist="$1"
    shift
    echo "Usage: $(basename "$(callerPath 1)") $arglist"
    for line in "$@"
    do
      echo "$line"
    done
    exit 1
  }

  # Include (source) bash script from standard lib location
  include_std() {
    (( $# == 1 )) || error "Missing argument: <file-name>"
    local includeFile="$STD_LIB/$1"
    source "$includeFile"
  }

  # Include (source) bash script with path relative to calling script itself.
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

  # Runs specified script resolving its name relative to the caller script
  # directory.
  # Usage: run <command> [ <args>... ]
  run() {
    (( $# >= 1 )) || error "Missing argument(s): <script> [ <args>... ]"
    local script
    script="$(callerDir 1)/$1"
    shift
    [[ -f "$script" ]] || die "Script not found: '$script'"
    $script "$@" || die "Failed to execute: [$script $*]"
  }

  if [ "${BASH_VERSINFO:-0}" -lt 5 ]
  then
    warn "ERROR: Insufficient bash version in $(basename "$0"): [$BASH_VERSION]. Version >= 5 required."
    warn "       MacOs hint: consider using [#!/usr/bin/env bash] instead of [#!/bin/bash]"
    traceback 1
    exit 1
  fi

fi

