#!/usr/bin/env bash

STD_LIB_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/lib"
MY_LIB_PATH="$(dirname "$(realpath "${BASH_SOURCE[1]}")")/lib"

error() {
  echo "${FUNCNAME[1]}: $*" 2>&1
  exit 1
}

include_std() {
  (( $# == 1 )) || error "Missing argument: <file-name>"
  local includeFile="$STD_LIB_PATH/$1"
  [[ -f "$includeFile" ]] || error "file does not exist: [$includeFile]"
  source "$includeFile"
}

include() {
  (( $# == 1 )) || error "Missing argument: <file-name>"
  local includeFile="$STD_LIB_PATH/$1"
  [[ -f "$includeFile" ]] || error "file does not exist: [$includeFile]"
  source "$MY_LIB_PATH/$1"
}
