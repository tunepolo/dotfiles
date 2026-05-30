#!/bin/bash

set -euo pipefail

# nvmのインストール（インストール済みならスキップ）
if [ ! -d "${NVM_DIR:-$HOME/.nvm}" ]; then
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
	# shellcheck disable=SC1091
	. "${NVM_DIR:-$HOME/.nvm}/nvm.sh"
	nvm install node
fi

./npm_install.sh
./mac_install.sh

# HomebrewでinstallしたGitのdiff-highlightを有効にする
# https://udomomo.hatenablog.com/entry/2019/12/01/181404
if [ ! -e /usr/local/bin/diff-highlight ]; then
	sudo ln -s /opt/homebrew/share/git-core/contrib/diff-highlight/diff-highlight /usr/local/bin/diff-highlight
fi
