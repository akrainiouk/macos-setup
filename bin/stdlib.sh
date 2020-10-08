# Bootstrap script that provides minimal functionality
# Allowing to include other library scripts (from lib directory)
# as well as basic support for error reporting

if [[ "${SHELLBOOST}" == "" ]]
then

  export SHELLBOOST=1

  export STD_LIB="$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")/lib"
  export SELF_DIR="$(dirname "$(realpath "${BASH_SOURCE[1]}")")"

  traceback() {
    # Hide the traceback() call.
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
      echo "    at ${func}(${file}:${line})" 1>&2
    done
  }

  error() {
    echo "ERROR: $*" 1>&2
    traceback 1
    return 1
  }

  die() {
    echo "ERROR: $*" 1>&2
    traceback 1
    exit 1
  }

  trace() {
    echo "TRACE: $*" 1>&2
  }

  intercept() {
    while read line
    do
      echo "INTERCEPT: $line" 1>&2
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
    line="$(cut -d ' ' -f 1 <<< "$stackFrame")"
    func="$(cut -d ' ' -f 2 <<< "$stackFrame")"
    path="$(sed -e 's/[^ ]* [^ ]* //g' <<< $stackFrame)"
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
    local includeFile="$(callerDir 1)/$1"
    if [[ -f "$includeFile" ]]
    then
      source "$includeFile"
    else
      error "File not found '$includeFile'"
    fi
  }

fi

