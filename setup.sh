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

for file in "${DOT_FILES[@]}"
do
    ln -fs "$HOME"/dotfiles/"$file" "$HOME"/"$file"
done

./npm_install.sh
./go_install.sh

