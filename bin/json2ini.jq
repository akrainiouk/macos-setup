#!/usr/bin/env jq --raw-output --from-file

def genProps:
  to_entries| map("\(.key) = \(.value)")
;

def genSection:
  [ "[\(.key)]" ] + (.value|genProps)
;

to_entries | map(genSection) | flatten[]