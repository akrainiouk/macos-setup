#!/bin/sh
if (( $# == 1 ))
then
  targetPath=$1
else
  targetPath="./"
fi
if [ ! -d "$targetPath/.idea" ]
then
  echo "$targetPath/.idea folder does not exist." 
  exit 1
fi

myPath=$0
while [ -L $myPath ]
do
  echo "link: $myPath"
  myPath=$(readlink $myPath)
done
myDir=$(dirname $myPath)
ln -s $myDir/copyright $targetPath/.idea/
