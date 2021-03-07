#!/usr/bin/env bash

mkdir -p $(brew --prefix)/etc/bash_completion.d
rustup completions bash rustup > $(brew --prefix)/etc/bash_completion.d/rustup.bash-completion
rustup completions bash cargo > $(brew --prefix)/etc/bash_completion.d/cargo.bash-completion

