#!/bin/bash
timeStamp=$(date "+%Y-%m-%d_%H.%M.%S")
backupDir="/tmp/config-backup-$timeStamp"
echo "Saving original setup into [$backupDir]"

mkdir -p $backupDir

installFile() {
  src="$(realpath $1)"
  dst="$2"
  case $dst in
    /*) 
    echo "dst [$dst] must be relative to user home"
    exit 1
    ;;
  esac
  if [[ -e $HOME/$dst ]]
  then
    mkdir -p $backupDir/$(dirname $dst)
    mv $HOME/$dst $backupDir/$dst
  fi
  ln -s $src $HOME/$dst
}

echo "Installing symlinks to startup scripts..."
installFile bashrc .bashrc
installFile bash_profile .bash_profile
installFile gitconfig .gitconfig
installFile vimrc .vimrc

