#!/usr/bin/env bash

if which -s brew
then
  echo "Homebrew is already installed. Skipping brew installation."
else
  echo "Installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

if ! brew ls --versions bash bash-completion > /dev/null
then
  brew install bash bash-completion
fi

if ! grep -q -e '/usr/local/bin/bash' /etc/shells
then
  echo "Whitelisting /usr/local/bin/bash"
  echo "/usr/local/bin/bash" | sudo tee -a /etc/shells > /dev/null
fi

if [[ "$(dscl . -read ~/ UserShell | sed 's/UserShell: //')" != "/usr/local/bin/bash" ]]
then
  echo "Changing default shell to /usr/local/bin/bash"
  chsh -s /usr/local/bin/bash
fi

# missing or gnue flavors of popular tools
brew install watch      # missing in MacOs
brew install coreutils  # realpath, greadlink
brew install findutils  # provides gfind
brew install bash       # gnue version of bash
brew install bash-completion

brew install source-highlight
brew install pandoc    # used by md-preview script
brew install pygments  # provides syntax highliting for YAML  
brew install htop      # nice alternative to top
# web development
brew install httpie    # dev friendly alternative to curl
brew install websocat  # curl for websocket protocol
#######################
# Development tools    
#######################
brew install java scala maven sbt
brew cask install oracle-jdk
# Kubernetes
brew cask install slack
brew cask install onedrive
brew cask install bluejeans
brew cask install firefox
brew cask install docker
brew cask install intellij-idea
brew install kubernetes-cli
brew install kubernetes-helm
# Yaml query
brew install jq yq
brew install keepassxc
# Mustache templating engine
sudo gem install mustache
