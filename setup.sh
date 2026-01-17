#!/bin/bash

# nvmのインストール
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
nvm install node

./npm_install.sh
./go_install.sh
./mac_install.sh

# HomebrewでinstallしたGitのdiff-highlightを有効にする
# https://udomomo.hatenablog.com/entry/2019/12/01/181404
sudo ln -s /opt/homebrew/share/git-core/contrib/diff-highlight/diff-highlight /usr/local/bin/diff-highlight
