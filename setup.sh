#!/bin/bash

# Create symbolic link
DOT_FILES=(
    .gitconfig
    .gvimrc
    .inputrc
    .irbrc
    .minttyrc
    .pryrc
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

