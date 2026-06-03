#!/usr/bin/env bash
# Homebrew で install した Git の diff-highlight を /usr/local/bin から参照可能にする。
# 既に symlink が存在する場合は何もしない。
# 参考: https://udomomo.hatenablog.com/entry/2019/12/01/181404

set -euo pipefail

TARGET="/usr/local/bin/diff-highlight"
SOURCE="/opt/homebrew/share/git-core/contrib/diff-highlight/diff-highlight"

if [ -e "${TARGET}" ]; then
	exit 0
fi

if [ ! -e "${SOURCE}" ]; then
	echo "diff-highlight source not found: ${SOURCE} (skip)"
	exit 0
fi

sudo ln -s "${SOURCE}" "${TARGET}"
