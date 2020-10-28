# Shared setup for MacOs


This project is intended to allow to easily transfer my customizations from one
MacOs machine to another and keep them in sync afterwards.

## Installation

1. Clone the project from git
2. Install [homebrew](https://docs.brew.sh/Installation) and its dependencies.
3. Install homebrew packages (not all are required)
    ```bash                 
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
    brew install git   
    # Kubernetes
    brew cask install docker
    brew install kubernetes-cli
    brew install kubernetes-helm
    # Yaml query
    brew install yq
    # Mustache templating engine
    gem install mustache
    ```
4. Configure your startup files
```bash
cd <project-root>
install.sh
```
then update .bashrc and .bash_profiles as it is at the end of the script run

# Post installation adjustments

## xml2json
checkout from https://github.com/hay/xml2json.git or download directly:
```bash
curl -o xml2json.py https://raw.githubusercontent.com/hay/xml2json/master/xml2json.py 
```                 
for human readable output use:
```
xml2json --strip_namespace --strip_text <input-file.xml>
```

## Intellij IDEA

### Fix autorepeat in embedded terminal ([detailed discussion](https://stackoverflow.com/questions/15107321/intellij-idea-auto-repetition-of-letter-keys))
```bash                                                                   
defaults write -g ApplePressAndHoldEnabled -bool false
```                                   
Restart Intellij IDEA in order for the fix to take effect

### Configure Groovy SDK
assuming groovy sdk is previously installed via:
```
brew install groovysdk
```
When prompted (e.g. on opening Jenkins file) choose
`/usr/local/Cellar/groovysdk/<version>/libexec` as library root directory
(Use `Command-Shift-G` in finder to copy/paste path)

### Fix find action (Command-Shift-A) shortcut

#### Enable three finger gragging
1. Open System *Preferences*/*Accessibility*/*Pointer* Control
2. Click *Trackpad Options*
3. Check *Enable dragging* checkbox choosing *three finger drag* in the dropdown list next to it.
#### Enable *Tap to click*
1. Open *System Preferences*/*Trackpad*
2. Check *Tap to click* checkbox.
#### Fix conflicting/annoying keyboard shortcuts.
1. Open system Preferences/Keyboard/Shortcuts
2. Under services find "Search man Page index in Terminal" and uncheck it.
3. While you are at it you can also disable "Open man Page in Terminal" near it to fix
"Move lines to another changelist" action in IDEA

## Features

### Project specific bash profiles

if *bash_profile* file is placed in the directory where new bash instance is starting
provided bashrc will execute it and change command prompt to mark that bash is running
in customized mode. *user@host* part of the prompt is replaced with either the
value of *PROJECT_NAME* environment variable or a name of a parent directory highlighted
in red. This feature allows automatically customize terminal instances running
inside IntelliJ IDEA.
