# Shared setup for macos

This project is intened to allow to easily transfer my customizations from one
MacOs machine to another and keep them in sync afterwards.

## Installation

1. Clone the project from git
2. Install [homebrew](https://docs.brew.sh/Installation) and its dependencies.
3. Install homebrew packages (not all are required)
    ```bash
    brew install watch
    brew install coreutils
    brew install findutils  # provides gfind
    brew install bash
    brew install bash-completion
    brew install git
    brew install source-highlight
    brew install pygments  # provides syntax highliting for YAML
    # web development
    brew install httpie    # dev friendly alternative to curl
    brew install websocat  # curl for websocket protocol
    # Kubernetes
    brew cask install docker
    brew install kubernetes-cli
    brew install kubernetes-helm
    # Yaml query
    brew install yq
    # Mustache templating engine
    gem install mustache
    ```
4. Confiture your startup files
```bash
cd <project-root>
install.sh
```
then update .bashrc and .bash_profiles as it is at the end of the script run

# Post installation adjustments

## Intellij IDEA

### Fix autorepeat in embedded terminal ([detailed discussion](https://stackoverflow.com/questions/15107321/intellij-idea-auto-repetition-of-letter-keys))
```bash                                                                   
defaults write -g ApplePressAndHoldEnabled -bool false
```                                   

### Fix find action (Command-Shift-A) shortcut

1. Open system Preferences/Keyboard/Shortcuts
2. Under services find "Search man Page index in Terminal" and uncheck it.
3. While you are at it you can also disable "Open man Page in Terminal" near it to fix
"Move lines to another changelist" action in IDEA