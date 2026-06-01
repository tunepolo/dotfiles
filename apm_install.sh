#!/usr/bin/env bash
# Microsoft Agent Package Manager (apm) のインストーラ。
# Homebrew 配布が無いため、Microsoft が提供する公式 curl|sh スクリプトを利用する。
# 既に PATH に apm がある場合は冪等的にスキップする。
# 参考: https://github.com/microsoft/apm

set -euo pipefail

INSTALLER_URL="https://aka.ms/apm-unix"

if command -v apm >/dev/null 2>&1; then
  echo "apm is already installed: $(command -v apm)"
  exit 0
fi

echo "Installing apm from ${INSTALLER_URL} ..."
curl -sSL "${INSTALLER_URL}" | sh
