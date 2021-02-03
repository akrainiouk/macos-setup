#!/usr/bin/env jq --from-file

def pathStr:
  reduce .[] as $x (
    "";
    if $x | type == "string" and test("^[A-Za-z][A-Za-z0-9_]*$") then
      . + "." + $x
    else
      . + "[" + ($x | tojson) + "]"
    end
  )
;

. as $root
| [paths(type=="string" and test($pattern))]
| map(
    . as $path
    | {
         value: $root | getpath($path),
         path:  $path | pathStr
       }
  )[]
