#!/usr/bin/env bash
# apm_install.sh の振る舞いを検証する。
# 実行: bash tests/apm-install.test.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
INSTALLER="${REPO_ROOT}/apm_install.sh"

PASS=0
FAIL=0
TMP_BASE="$(mktemp -d)"
trap 'rm -rf "${TMP_BASE}"' EXIT

assert_eq() {
  local expected="$1" actual="$2" label="$3"
  if [[ "${actual}" == "${expected}" ]]; then
    echo "  ok: ${label}"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: ${label} (expected=${expected} actual=${actual})"
    FAIL=$((FAIL + 1))
  fi
}

assert_no_match() {
  local pattern="$1" file="$2" label="$3"
  if grep -q "${pattern}" "${file}"; then
    echo "  FAIL: ${label} (pattern '${pattern}' found in output)"
    FAIL=$((FAIL + 1))
  else
    echo "  ok: ${label}"
    PASS=$((PASS + 1))
  fi
}

[[ -x "${INSTALLER}" ]] || { echo "installer not found or not executable: ${INSTALLER}"; exit 2; }

# curl|sh を絶対に呼ばないことを保証するために、テスト用に最小限の PATH を組み立てる。
# システムの curl がある場所を除いた PATH に、スタブ用 bin を先頭で結合する。
SYS_PATH="/usr/bin:/bin:/usr/sbin:/sbin"

echo "case 1: apm が PATH に存在する場合は curl を呼ばずに 0 終了"
STUB1="${TMP_BASE}/case1/bin"
mkdir -p "${STUB1}"
cat >"${STUB1}/apm" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${STUB1}/apm"

# curl が呼ばれたら検知できるよう、明確なマーカーを残すスタブを用意する。
cat >"${STUB1}/curl" <<'STUB'
#!/usr/bin/env bash
echo "APM_TEST_CURL_INVOKED" >&2
exit 99
STUB
chmod +x "${STUB1}/curl"

OUT1="${TMP_BASE}/case1.out"
PATH="${STUB1}:${SYS_PATH}" bash "${INSTALLER}" >"${OUT1}" 2>&1
rc=$?
assert_eq 0 "$rc" "既存 apm 検出時の終了コードが 0"
assert_no_match "APM_TEST_CURL_INVOKED" "${OUT1}" "curl が呼び出されていない"

echo ""
echo "case 2: apm が無い場合は curl 経由のインストーラを実行し、成功時に 0 終了"
STUB2="${TMP_BASE}/case2/bin"
mkdir -p "${STUB2}"
# apm スタブは置かない → command -v apm は失敗する想定
# curl スタブは fake インストーラを stdout に出力し、それを sh が受けて実行する。
# fake インストーラは何もせずに 0 終了するだけ。
cat >"${STUB2}/curl" <<'STUB'
#!/usr/bin/env bash
echo "APM_TEST_CURL_INVOKED" >&2
# 引数を tmp ファイルに記録（URL を含むことを後で検証）
echo "$*" >"${APM_TEST_CURL_ARGS_FILE}"
# パイプ先の sh が読む内容（no-op スクリプト）
printf '#!/bin/sh\nexit 0\n'
STUB
chmod +x "${STUB2}/curl"

ARGS_FILE="${TMP_BASE}/case2.curl_args"
OUT2="${TMP_BASE}/case2.out"
APM_TEST_CURL_ARGS_FILE="${ARGS_FILE}" \
  PATH="${STUB2}:${SYS_PATH}" \
  bash "${INSTALLER}" >"${OUT2}" 2>&1
rc=$?
assert_eq 0 "$rc" "新規インストール時の終了コードが 0"

if grep -q "APM_TEST_CURL_INVOKED" "${OUT2}"; then
  echo "  ok: curl が呼び出された"
  PASS=$((PASS + 1))
else
  echo "  FAIL: curl が呼び出されていない"
  FAIL=$((FAIL + 1))
fi

if [[ -f "${ARGS_FILE}" ]] && grep -q "aka.ms/apm-unix" "${ARGS_FILE}"; then
  echo "  ok: 公式 URL (aka.ms/apm-unix) が curl 引数に含まれる"
  PASS=$((PASS + 1))
else
  echo "  FAIL: 公式 URL が curl 引数に含まれない"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "case 3: curl が失敗した場合は非 0 終了する"
STUB3="${TMP_BASE}/case3/bin"
mkdir -p "${STUB3}"
cat >"${STUB3}/curl" <<'STUB'
#!/usr/bin/env bash
exit 22
STUB
chmod +x "${STUB3}/curl"

OUT3="${TMP_BASE}/case3.out"
PATH="${STUB3}:${SYS_PATH}" bash "${INSTALLER}" >"${OUT3}" 2>&1
rc=$?
if [[ "$rc" -ne 0 ]]; then
  echo "  ok: curl 失敗時に非 0 終了 (exit=${rc})"
  PASS=$((PASS + 1))
else
  echo "  FAIL: curl 失敗が伝播していない (exit=0)"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "結果: ${PASS} pass / ${FAIL} fail"
[[ "${FAIL}" -eq 0 ]]
