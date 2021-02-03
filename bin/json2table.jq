#!/usr/bin/env jq --slurp --raw-output --from-file
# Generate JSON stream to JIRA formatted table
# Usage json2jira <input-file>

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

def tableContent(columns): . as $value | columns | map($value[.]) | tableRow("|");

def collectHeader: reduce .[] as $item ({}; . + ($item | with_entries(.value={}))) | keys;

collectHeader as $keys |
($keys | tableHeader),
 map(tableContent($keys))[]