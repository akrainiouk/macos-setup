export KUBECONFIG="$HOME/.kube/config:$HOME/.kube/contexts.yaml:$HOME/.kube/clusters.yaml"

if [ -r $HOME/.bashrc ]
then
    . $HOME/.bashrc
fi

# Configuration for interactive shell only

# Enable line nubmers in less
export LESS="R"
# export LESSOPEN="| src-hilite-lesspipe.sh %s"

# Enable bash completion
if [ -f $(brew --prefix)/etc/profile.d/bash_completion.sh ]
then
    . $(brew --prefix)/etc/profile.d/bash_completion.sh
fi

# Initialize bash completion for kubectl
tmpfile=$(mktemp /tmp/kubectl-completion.XXXXXX)
kubectl completion bash > $tmpfile
. $tmpfile

# Setting PATH for Python 3.8
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.8/bin:${PATH}"
export PATH

if [[ -d $HOME/.bash_profile.d ]]
then
  for script in $(find $HOME/.bash_profile.d -type f)
  do
    . $script
  done
fi
