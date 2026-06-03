#!/usr/bin/env bash
# .chezmoiscripts 配下のセットアップスクリプトの振る舞いを検証する。
# 実行: bash tests/chezmoiscripts.test.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CHEZMOI_SCRIPTS_DIR="${REPO_ROOT}/.chezmoiscripts"

PASS=0
FAIL=0

pass() { echo "  ok: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

assert_exit() {
  local expected="$1" actual="$2" label="$3"
  if [[ "${actual}" == "${expected}" ]]; then
    pass "${label} (exit=${actual})"
  else
    fail "${label} (expected=${expected} actual=${actual})"
  fi
}

assert_file_contains() {
  local file="$1" pattern="$2" label="$3"
  if grep -qE "${pattern}" "${file}"; then
    pass "${label}"
  else
    fail "${label} (pattern not found: ${pattern})"
  fi
}

EXPECTED_SCRIPTS=(
  "run_once_after_01_macos-defaults.sh"
  "run_once_after_02_diff-highlight.sh"
  "run_once_after_03_npm-globals.sh"
)

echo "case 1: .chezmoiscripts に期待するスクリプトが存在する"
for s in "${EXPECTED_SCRIPTS[@]}"; do
  if [[ -f "${CHEZMOI_SCRIPTS_DIR}/${s}" ]]; then
    pass "${s} exists"
  else
    fail "${s} not found at ${CHEZMOI_SCRIPTS_DIR}/${s}"
  fi
done

echo "case 2: 各スクリプトに bash シェバンと set オプションが記述されている"
for s in "${EXPECTED_SCRIPTS[@]}"; do
  f="${CHEZMOI_SCRIPTS_DIR}/${s}"
  [[ -f "$f" ]] || { fail "${s} not found (skip shebang/set check)"; continue; }
  assert_file_contains "$f" '^#!/usr/bin/env bash' "${s} has bash shebang"
  assert_file_contains "$f" '^set -euo pipefail' "${s} sets strict mode"
done

echo "case 3: macOS defaults スクリプトは非 Darwin で 0 終了する（chezmoi apply を止めない）"
MACOS_SCRIPT="${CHEZMOI_SCRIPTS_DIR}/run_once_after_01_macos-defaults.sh"
if [[ -f "${MACOS_SCRIPT}" ]]; then
  STUB_DIR="$(mktemp -d)"
  cat >"${STUB_DIR}/uname" <<'EOF'
#!/usr/bin/env bash
echo "Linux"
EOF
  chmod +x "${STUB_DIR}/uname"
  PATH="${STUB_DIR}:/usr/bin:/bin" bash "${MACOS_SCRIPT}" >/dev/null 2>&1
  rc=$?
  rm -rf "${STUB_DIR}"
  assert_exit 0 "${rc}" "non-Darwin での実行は 0 終了"
else
  fail "${MACOS_SCRIPT} not found (skip non-Darwin behavior check)"
fi

echo "case 4: npm globals スクリプトは npm が無いとき 0 終了する"
NPM_SCRIPT="${CHEZMOI_SCRIPTS_DIR}/run_once_after_03_npm-globals.sh"
if [[ -f "${NPM_SCRIPT}" ]]; then
  STUB_DIR="$(mktemp -d)"
  PATH="${STUB_DIR}:/usr/bin:/bin" bash "${NPM_SCRIPT}" >/dev/null 2>&1
  rc=$?
  rm -rf "${STUB_DIR}"
  assert_exit 0 "${rc}" "npm 不在での実行は 0 終了"
else
  fail "${NPM_SCRIPT} not found (skip npm-missing behavior check)"
fi

echo ""
echo "結果: ${PASS} pass / ${FAIL} fail"
[[ "${FAIL}" -eq 0 ]]
