#!/bin/sh

# Update npm itself
npm update -g npm

# Install npm-check-updates
npm install -g npm-check-updates

# Install git-delete-squashed
# https://github.com/not-an-aardvark/git-delete-squashed
npm install -g git-delete-squashed

# mabl-cli
npm i -g @mablhq/mabl-cli
