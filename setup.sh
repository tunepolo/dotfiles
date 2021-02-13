#!/bin/bash

# Create symbolic link
DOT_FILES=(
    .gemrc
    .gitconfig
    .inputrc
    .irbrc
    .minttyrc
    .pryrc
    .ptconfig.toml
    .tigrc
    .vimrc
    .zshenv
    .zshrc
)

for file in "${DOT_FILES[@]}"; do
    ln -fs "$HOME"/dotfiles/"$file" "$HOME"/"$file"
done

# nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
nvm install node

./npm_install.sh
./go_install.sh
./mac_install.sh

# HomebrewでinstallしたGitのdiff-highlightを有効にする
# https://udomomo.hatenablog.com/entry/2019/12/01/181404
sudo ln -s /usr/local/share/git-core/contrib/diff-highlight/diff-highlight /usr/local/bin/diff-highlight
