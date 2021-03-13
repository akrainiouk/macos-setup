#!/usr/bin/env bash
source lib-std.bash

dockerApp="/Applications/Docker.app/"
[[ -d "$dockerApp" ]] || reject "Directory does not exist: '$dockerApp'" "Install docker (brew --cask install docker)"
completionPath="$dockerApp/Contents/Resources/etc"
[[ -d "$completionPath" ]] || reject "Directory does not exit: '$completionPath'"

cd "$(brew --prefix)/etc/bash_completion.d"
ln -s "$completionPath/docker.bash-completion"
ln -s "$completionPath/docker-compose.bash-completion"

