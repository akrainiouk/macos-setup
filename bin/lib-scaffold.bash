# Provides systemic approach to error handling in bash scripts
# Usage: 
#   source lib-scaffold.bash
#
# This will configure bash to exit immediately if any command returns non-zero status
# also printing a call stack to help with troubleshooting.
# To make returned errors predictable, intercepted error codes are replaced with a single
# value - SCAFFOLD_SCRIPT_ERROR (252)  
#
# scaffold.exitCode <command> [ <arguments>... ]
# In addition, several convenience functions are provided:
# scaffold.fail [ -<exit-code> ] [ <messages>... ]
#   - exits with specified error code printing out a message and the call stack
# scaffold.reject [ -<exit-code> ] [ <messages>... ]
#   - exits with specified error code printing out provided messages but without the call stack
# 
if [[ "$LIB_SCAFFOLD" == "" ]]; then
  
  declare -r LIB_SCAFFOLD="$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")/lib"

  ###############################################
  # Public API
  ###############################################

  # Reserved error codes
  
  # Indicates that one of the script commands returned error status.
  # Accompanied by the stack trace and used to indicate an error
  # condition intercepted by ERR trap
  declare -r SCAFFOLD_SCRIPT_ERROR=252
  
  # Generic failure (like AssertionError in java). Raised by default by scaffold.fail
  # Should be accompanied by the stack trace.
  declare -r SCAFFOLD_ASSERTION_ERROR=253
  
  # Precondition failed. Raised by default by scaffold.reject.
  # For example as a result of checking of script invocation arguments.
  # For these errors stack trace should not be printed.
  declare -r SCAFFOLD_PRECONDITION_ERROR=254

  # Exit code last captured by scaffold.exitCode function
  declare -i scaffold_capturedExitCode=0
  
  # Runs specified command capturing and printing its exitCode to stdout.
  # This function should be used to capture exit code prior to using it in
  # if or while statement or boolean expression.
  # This way it preserves error trapping behavior inside tested code.
  scaffold.run() {
    (( $# >= 1 )) || scaffold.fail "Missing argument <cmd>"
    local -i capturedExitCode=0
    handleError() {
      capturedExitCode=$?
      return 0
    }
    trap handleError ERR
    scaffold_private_errorCaptureDepth=$(( $scaffold_private_errorCaptureDepth + 1 ))
    ( # Run command in a subshell exiting on the first error and propagating original
      # exit code
      trap 'exit $?' ERR
      "$@"
    )
    scaffold_private_errorCaptureDepth=$(( $scaffold_private_errorCaptureDepth - 1 ))
    if (( $scaffold_private_errorCaptureDepth == 0 )); then
      echo "Restoring error handler"
      trap scaffold_private.handleError ERR
    fi
    scaffold_capturedExitCode="$capturedExitCode"
  }

  # Prints error message followed by stack trace to stderr and exits with specified exit code
  # Usage: scaffold.fail [ -<exit-code> ] [ <messages>... ]
  # Default error-code is ERROR_ASSERTION_FAILED
  scaffold.fail() {
    local -i exitCode=$SCAFFOLD_ASSERTION_ERROR
    if (( $# > 0 )) && scaffold_private.isNegativeInt "$1"; then
      exitCode=$((-$1))
      shift
    fi
    scaffold_private.printError "$@"
    scaffold_private.traceback 1 1>&2
    exit $exitCode
  }

  # Prints supplied error messages and exits without printing stack trace
  # dumping stack trace
  # Usage reject [ -<error-code> ] [ <messages>... ]
  scaffold.reject() {
    local -i exitCode=$SCAFFOLD_PRECONDITION_ERROR
    if (( $# > 0 )) && scaffold_private.isNegativeInt "$1"; then
      exitCode=$(( -$1 ))
      shift
    fi
    scaffold_private.printError "$@"
    exit $exitCode
  }

  ###############################################
  # Private
  ###############################################
  
  # Used to detect exit code option which is in -<integer> format
  declare -r scaffold_private_regex_NegativeInt="^-[0-9]+$"
  
  # Keeps track of scaffold.run nesting level in order
  # to detect when it is time to restore default error handler
  declare -i scaffold_private_errorCaptureDepth=0
  
  scaffold_private.isNegativeInt() {
    [[ "$1" =~ $scaffold_private_regex_NegativeInt ]]
  }
  
  scaffold_private.printLines() {
    for line in "$@"; do
      echo "$line"
    done
  }

  scaffold_private.printError() {
    if (( $# > 0 )); then
      local firstLine="ERROR: $1"
      shift
      scaffold_private.printLines "$firstLine" "$@" 1>&2
    fi
  }

  scaffold_private.handleError() {
    local errorCode="$?"
    scaffold_private.printError "Intercepted errorCode: $errorCode. Exiting with code $SCAFFOLD_SCRIPT_ERROR (internal error)"
    scaffold_private.traceback 1 1>&2
    exit $SCAFFOLD_SCRIPT_ERROR
  }
  
  # Prints out caller source reference formatted in such a way
  # that frames can be navigated in Intellij IDEA
  # Usage: callerSource [ <level> ]
  scaffold_private.callerSource() {
    local -i level
    local frame line func path
    level=$((${1:-1}))
    func="${FUNCNAME[$level]}"
    file="$(realpath "${BASH_SOURCE[$level]}")" || file="${BASH_SOURCE[$level]}"
    line="${BASH_LINENO[(($level - 1))]}"
    echo "    at $func($file:$line)"
  }

  # Prints out a call stack trace
  # Usage: scaffold.traceback <level>
  # Where level is the minimum stack depth to report (defaults to 0)
  scaffold_private.traceback() {
    echo "Call stack:"
    # Hide the traceback() call itself.
    local -i start=$((${1:-0} + 1))
    local -i end=${#BASH_SOURCE[@]}
    local -i i=0
    for ((i = start; i < end; i++)); do
      scaffold_private.callerSource $((i + 1))
    done
  }

  set -o errtrace -o pipefail 
  trap scaffold_private.handleError ERR

fi

