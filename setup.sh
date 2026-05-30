#!/bin/bash

set -euo pipefail

# Ruby / Python / Node のバージョンは mise で管理する。
# 必要なバージョンは各リポジトリの .tool-versions / .node-version 等に記述すれば
# cd 時に自動で読み込まれる。グローバル版を入れたい場合は以下を実行：
#   mise use --global node@lts ruby@latest python@latest

./npm_install.sh
./mac_install.sh

# HomebrewでinstallしたGitのdiff-highlightを有効にする
# https://udomomo.hatenablog.com/entry/2019/12/01/181404
if [ ! -e /usr/local/bin/diff-highlight ]; then
	sudo ln -s /opt/homebrew/share/git-core/contrib/diff-highlight/diff-highlight /usr/local/bin/diff-highlight
fi
