# Process mustache template
# Usage:
#  processTemplate <src-srcFile> <dst-srcFile> key=val [key=val...]
# Safe - will error out if dst-srcFile already exists instead of overwriting
#
processTemplate() {
  local srcFile=$1
  local dstFile=$2
  shift 2
  echo "$srcFile -> $dstFile"
  if [[ -e $dstFile ]]
  then
    echo "File exists: $dstFile"
    error 1
  fi

  # build YAML data
  local data=""
  for arg in "$@"
  do
    key=$(echo $arg | cut -f 1 -d "=")
    val=$(echo $arg | cut -f 2 -d "=")
    data=$data$(echo "$key: '$val'")
  done

  mkdir -p "$(dirname $dstFile)"
  echo $data | mustache - $srcFile > $dstFile
}

# Process templates in the specified directory and its subdirectories
# storing generated files under specified path
# Usage:
#   processTemplates <template-dir> <output-dir> key=val [key=val...]
#
processTemplates() {
  local srcPath="$1"
  local dstPath="$2"
  shift 2
  for srcFile in $(gfind $srcPath -type f -name '*.mustache' -printf "%P\n")
  do
    dstFile="${srcFile%.mustache}"
    processTemplate $srcPath/$srcFile $dstPath/$dstFile "$@"
  done
}
