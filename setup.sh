#!/bin/bash

# Create symbolic link
DOT_FILES=(
    .gitconfig
    .gvimrc
    .inputrc
    .minttyrc
    .pryrc
    .tigrc
    .vimrc
    .zshenv
    .zshrc
)

for file in "${DOT_FILES[@]}"
do
    ln -s "$HOME"/dotfiles/"$file" "$HOME"/"$file"
done

# shellcheck disable=SC1090
{
    source ~/.zshenv
    source ~/.zshrc
}