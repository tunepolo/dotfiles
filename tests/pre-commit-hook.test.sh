#!/usr/bin/env bash
# git テンプレートに配置される pre-commit フックの振る舞いを検証する。
# 実行: bash tests/pre-commit-hook.test.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
HOOK_SRC="${REPO_ROOT}/dot_git-templates/secrets/hooks/executable_pre-commit"

PASS=0
FAIL=0
TMP_BASE="$(mktemp -d)"
trap 'rm -rf "${TMP_BASE}"' EXIT

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "missing dependency: $1"; exit 2; }
}

assert_exit() {
  local expected="$1" actual="$2" label="$3"
  if [[ "${actual}" == "${expected}" ]]; then
    echo "  ok: ${label} (exit=${actual})"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: ${label} (expected=${expected} actual=${actual})"
    FAIL=$((FAIL + 1))
  fi
}

setup_repo() {
  local d="$1"
  git init -q -b main "$d"
  git -C "$d" config user.email test@example.com
  git -C "$d" config user.name test
  install -m 0755 "${HOOK_SRC}" "$d/.git/hooks/pre-commit"
}

require git
require betterleaks
[[ -f "${HOOK_SRC}" ]] || { echo "hook source not found: ${HOOK_SRC}"; exit 2; }

echo "case 1: クリーンな staged 内容では 0 終了"
D1="${TMP_BASE}/clean"
setup_repo "$D1"
echo "hello world" >"$D1/file.txt"
git -C "$D1" add file.txt
(cd "$D1" && ./.git/hooks/pre-commit) >/dev/null 2>&1
assert_exit 0 "$?" "clean diff passes"

echo "case 2: 秘密鍵を含む staged 内容では非 0 終了"
D2="${TMP_BASE}/leak"
setup_repo "$D2"
{
  printf -- '-----BEGIN RSA PRIVATE KEY-----\n'
  printf -- 'MIIEpAIBAAKCAQEAtPVqdWQwiOeUWZQyKt8FK2sFAKEFAKEFAKEFAKEFAKEFAKE\n'
  printf -- '-----END RSA PRIVATE KEY-----\n'
} >"$D2/leak.pem"
git -C "$D2" add leak.pem
(cd "$D2" && ./.git/hooks/pre-commit) >/dev/null 2>&1
assert_exit 1 "$?" "leak detected"

echo ""
echo "結果: ${PASS} pass / ${FAIL} fail"
[[ "${FAIL}" -eq 0 ]]
