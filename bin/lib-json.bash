if [[ ! -v STD_LIB ]]
then
  source lib-std.bash
  die "[source lib-std.bash] is required"
fi

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
  jq --raw-output --exit-status "$2" <<< "$1" || die "Json value not found: '$2' in '$1'"
}
