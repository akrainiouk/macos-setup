# .bashrc
# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

self=$(realpath $BASH_SOURCE)
selfDir=$(dirname $self)

mkdir -p /tmp/akrainio

export MACPORTS_PREFIX=/opt/local
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# User specific aliases and functions
export PS1='[\u@\h \W]\$ '

export M2_HOME=$HOME/lib/maven
#export MAVEN_OPTS="-XX:MaxPermSize=400m -Xmx2000m"
export DERBY_HOME=$HOME/lib/derby
export JAVA_HOME=$HOME/lib/java
export ANDROID_HOME=$HOME/lib/android
export ANT_OPTS="-Xms512M -Xmx2048M -Xss1M -XX:MaxPermSize=128M"
export PLAY2_HOME=$HOME/lib/play

#export IDEA_JDK=/opt/java6
#export IDEA_PROPERTIES=$HOME/.IntelliJIdea90/idea.properties
#export IDEA_VM_OPTIONS=$HOME/.IntelliJIdea90/idea.vmoptions
#export IDEA_JDK=/etc/alternatives/java_sdk

export P4CONFIG=$HOME/.p4config
export DYLD_LIBRARY_PATH=$HOME/lib/fbxsdk/lib/clang/release:/opt/yjp/bin/linux-amd64:$HOME/bin/mac/lib
#export ICAROOT=/opt/ica-client

PATH=/usr/local/bin:$PATH
PATH=/usr/local/sbin:$PATH
PATH=/opt/bin:$PATH
PATH=$M2_HOME/bin:$PATH
PATH=$HOME/lib/yjp/bin:$PATH
PATH=$JAVA_HOME/bin:$PATH
PATH=$HOME/lib/mongodb/bin:$PATH
PATH=$HOME/lib/scala/bin:$PATH
PATH=$HOME/bin:$PATH
PATH=$HOME/bin/mac/bin:$PATH
PATH=/opt/jvmstat/bin:$PATH
PATH=$HOME/lib/sbt/bin:$PATH
PATH=$HOME/lib/spark/bin:$PATH
PATH=$HOME/lib/ant/bin:$PATH
PATH=$HOME/lib/kafka/bin:$PATH
PATH=$selfDir/bin:$PATH

if [[ -d $HOME/.bashrc.d ]]
then
  for script in $(find $HOME/.bashrc.d -type f)
  do
    . $script
  done
fi
