#!/bin/bash
#
# Tracebacks in bash
# https://docwhat.org/tracebacks-in-bash/
#
# Just take the code between the "cut here" lines
# and put it in your own program.
#
# Written by Christian Höltje
# Donated to the public domain in 2013

set -eu

trap _exit_trap EXIT
trap _err_trap ERR
_showed_traceback=f

function _exit_trap
{
  local _ec="$?"
  if [[ $_ec != 0 && "${_showed_traceback}" != t ]]; then
    traceback 1
  fi
}

function _err_trap
{
  local _ec="$?"
  local _cmd="${BASH_COMMAND:-unknown}"
  traceback 1
  _showed_traceback=t
  echo "The command ${_cmd} exited with exit code ${_ec}." 1>&2
}

function traceback
{
  # Hide the traceback() call.
  local -i start=$(( ${1:-0} + 1 ))
  local -i end=${#BASH_SOURCE[@]}
  local -i i=0
  local -i j=0

  echo "Traceback (last called is first):" 1>&2
  for ((i=start; i < end; i++)); do
    j=$(( i - 1 ))
    local function="${FUNCNAME[$i]}"
    local file="${BASH_SOURCE[$i]}"
    local line="${BASH_LINENO[$j]}"
    echo "     ${function}() in ${file}:${line}" 1>&2
  done
}

error() {
  local exitCode=${1:0}
  set +eu
  trap - EXIT
  trap - ERR
  exit $exitCode
}

ROOT_PATH="$(realpath $(bash-include-path)/..)"
DATA_PATH="$ROOT_PATH/data/$(basename $0)"

# fixes readlink compatibility between macos and linux
read_link() {
  case $OSTYPE in
  darwin*)
    greadlink -f $1
    ;;
  *)
    readlink -f $1
    ;;
  esac
}

initGit() {
  path=$1
  cd $path || exit 1
  if [[ -e .git ]]
  then
    echo "Git already initialized in [$PWD]"
    exit 1
  fi
  git init
  git add .
  git commit -m "Initial commit"
}
