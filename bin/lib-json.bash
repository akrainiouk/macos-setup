if [[ ! -v LIB_JSON ]]; then

  declare -r LIB_JSON="${BASH_SOURCE[0]}"

  if [[ ! -v LIB_STD ]]
  then
    source lib-std.bash
    die "[source lib-std.bash] is required"
  fi

  jsonRequest() {

    sanitizeHeaders() {
      local header
      while read header
      do
        if [[ "$header" =~ "=========" ]]
        then
          break
        elif [[ "$header" != "" ]]
        then
          headerName="$(sed -E 's/^([^:]+).*$/\1/g' <<< "$header" | tr '[:upper:]' '[:lower:]')"
          headerValue="$(sed -E 's/^[^:]+: *//g' <<< "$header")"
          jq --null-input --arg key "$headerName" --arg value "$headerValue" '{ key: $key, value: $value }'
        fi
      done | jq --slurp 'from_entries'
    }

    local headerFile contentFile headerDump responseCode headers
    headerFile="$(mktemp)"
    contentFile="$(mktemp)"
    stdErr="$(
      curl --silent --show-error \
          --dump-header "$headerFile" \
          --output "$contentFile" \
          "$@" 2>&1
    )" || die "[$(basename "$0") $*]" "$stdErr"
    headerDump="$(dos2unix < "$headerFile")"
    responseCode="$(head -n 1 <<< "$headerDump" | cut -f 2 -d ' ')"
    headers="$(tail -n +2 <<< "$headerDump" | sanitizeHeaders)"
  #  echo "ResponseCode: '$responseCode'"
  #  echo "Headers: '$headers'"
    contentType="$(jsonGet "$headers" '.["content-type"]')"
    case "$contentType" in
    application/json*) jqOptions=() ;;
    "application/vnd.api+json") jqOptions=() ;;
    *) jqOptions=( "--raw-input" "--slurp" ) ;;
    esac
    jq "${jqOptions[@]}" --argjson status "$responseCode" \
         --argjson headers "$headers" \
         '{ status: $status, headers: $headers, content: . }' \
         "$contentFile"
  }

  # Print json data from a file. Both json and yaml formats
  # are supported. The data is always converted to json.
  # Usage:
  #   jsonRead <file>
  jsonRead() {
    (( $# == 1 )) || die "Missing argument <file>"
    [[ -f "$1" ]] || die "File not found: '$1'"
    yq eval . "$1" --tojson
  }

  # Runs specified jq query on the specified JSON object
  # Usage:
  #   jsonGet <json> <jq-query>
  #
  jsonGet() {
    (( $# == 2 )) || die "Missing argument(s) in [$*], expected: <json> <query>"
    jq --compact-output \
       --raw-output \
       "$2" <<< "$1" \
    || die "Json value not found: '$2' in '$1'"
  }

  jsonTest() {
    (( $# == 2 )) || die "Missing argument(s) in [$*], expected <json> <query>"
    jq --exit-status "$2" > /dev/null <<< "$1"
  }

fi
