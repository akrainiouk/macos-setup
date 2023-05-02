#!/usr/bin/env jq --raw-output --from-file
# Generate JSON stream to JIRA formatted table
# Usage json2jira [ <input-file> ] [ --arg format <output-format> ]
# Where <output-format> is either 'jira' or 'markdown'

def formatCell: tostring | gsub("&"; "&amp;") | gsub("\\|"; "&vert;") | gsub("\n"; "&NewLine;");

def tableRow(colSep): map(formatCell) | colSep + " " + join(" " + colSep + " ") + " " + colSep;

def markdownHeader: tableRow("|"), (map("---") | tableRow("|"));

def jiraHeader: tableRow("||");

def tableHeader:
  if $ARGS.named.format | ((. | not) or . == "jira") then
    jiraHeader
  elif $ARGS.named.format == "markdown" then
    markdownHeader
  else
    "Unsupported format: " + . | halt_error(1)
  end
;

def tableContent(columns): . as $value | columns | map($value[.] // "") | tableRow("|");

# An alternative to an embedded keys function that
# preserves the original order of object keys
def orderedKeys: to_entries|map(.key);

# Collects column names for the table header by scanning all entries for keys.
# Keys are collected in the order they first appear in subsequent elements.
def collectHeader: reduce .[] as $item ({}; . + ($item | with_entries(.value={}))) | orderedKeys;

if type != "array" then
  "Invalid input. Input must be an array of objects but was " + type | halt_error(2)
elif all(type == "object") | not then
  "Invalid input. Not all elements of input array are of type object" | halt_error(2)
else
  collectHeader as $keys |
  ($keys | tableHeader),
  map(tableContent($keys))[]
end
