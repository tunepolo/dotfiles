#!/bin/bash

# Create symbolic link
DOT_FILES=(
    .gemrc
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

# Git
mkdir -p "$HOME"/.config/git
ln -fs "$HOME"/dotfiles/git/config "$HOME"/.config/git/config
ln -fs "$HOME"/dotfiles/git/ignore "$HOME"/.config/git/ignore

# nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
nvm install node

./npm_install.sh
./go_install.sh
./mac_install.sh

# HomebrewでinstallしたGitのdiff-highlightを有効にする
# https://udomomo.hatenablog.com/entry/2019/12/01/181404
sudo ln -s /opt/homebrew/share/git-core/contrib/diff-highlight/diff-highlight /usr/local/bin/diff-highlight
