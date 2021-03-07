#!/usr/bin/env bash

source stdlib.sh
source cli.sh

declare -a args
declare -A opts

parseCommandLine args opts "$@"

echo "Args: ${args[*]}"
echo "Options:"
for opt in "${!opts[@]}"
do
  echo "$opt: ${opts["$opt"]}"
done