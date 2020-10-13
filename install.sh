#!/bin/bash

targetRef="$HOME/lib/macos-setup"
targetPath="$HOME/lib/versions/macos-setup-SNAPSHOT"
self="$(realpath --canonicalize-existing "$0")"
sourcePath="$(dirname "$self")"
timeStamp="$(date "+%Y-%m-%d_%H_%M.%S")"
backupDir="/tmp/config-backup-$timeStamp"

error() {
  echo "$1"
  exit 1
}

bold() {
  echo -e "\033[1m$1\033[0m"
}

underscore() {
  echo -e "\033[4m$1\033[0m"
}

#echo "self:      [$self]"
#echo "srcPath:   [$sourcePath]"
#echo "dstPath:   [$targetPath]"
#echo "backupDir: [$backupDir]"

! test -e "$targetRef"  || error "Path [$targetRef] already exists"
! test -e "$targetPath" || error "Path [$targetPath] already exists"

echo "Saving original setup into [$backupDir]"
mkdir -p "$backupDir"

mkdir -p "$(dirname "$targetPath")"
ln -s "$sourcePath" "$targetPath"
ln -s "$targetPath" "$targetRef"

installSymlink() {
  local src dst
  src="$(realpath "$1")"
  dst="$2"
  case $dst in
  /*)
    echo "dst [$dst] must be relative to user home"
    exit 1
    ;;
  esac
  if [[ -e "$HOME/$dst" || -L "$HOME/$dst" ]]
  then
    mkdir -p "$backupDir/$(dirname "$dst")"
    mv "$HOME/$dst" "$backupDir/$dst"
  fi
  ln -s "$src" "$HOME/$dst"
}

echo "Installing symlinks to configuration files..."
for file in $(gfind $sourcePath/config -type f -printf "%P\n")
do
  # shellcheck disable=SC2088
  echo "~/.$file -> $targetRef/config/$file"
  installSymlink "$targetRef/config/$file" ".$file"
done

echo "
Installation complete. Add the following lines to your startup
scripts right before any exiting customizations:
"
# shellcheck disable=SC2088
underscore "~/.bashrc":
bold "    source $targetRef/startup/bashrc"
echo
# shellcheck disable=SC2088
underscore "~/.bash_profile":
bold "    source $targetRef/startup/bash_profile"
echo
