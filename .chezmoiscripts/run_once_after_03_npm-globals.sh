#!/usr/bin/env bash
# グローバルに常駐させたい npm パッケージを install する。
# npm が無い環境（mise で node 未導入など）ではスキップして chezmoi apply を止めない。

set -euo pipefail

if ! command -v npm >/dev/null 2>&1; then
	echo "npm not found, skip npm globals"
	exit 0
fi

# Update npm itself
npm update -g npm

# Install npm-check-updates
npm install -g npm-check-updates

# Install git-delete-squashed
# https://github.com/not-an-aardvark/git-delete-squashed
npm install -g git-delete-squashed
