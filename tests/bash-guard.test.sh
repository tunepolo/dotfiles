#!/usr/bin/env bash
# Claude Code の PreToolUse フック bash-guard.sh の判定を検証する。
# 実行: bash tests/bash-guard.test.sh
#
# 判定対象のコマンド文字列は展開せずそのままフックへ渡す必要がある
# shellcheck disable=SC2016

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
GUARD="${REPO_ROOT}/dot_claude/hooks/bash-guard.sh"

# 承認を要する経路で deny を回避できる長さの説明。目的・副作用・可逆性を書けば
# 自然に超える量で、閾値ちょうどの検査は case 8 で別に行う。
DESC_OK="統合テストを実行する。localhost:5432 の Postgres に接続し public スキーマを truncate して seed を入れ直す。使い捨て DB なので compose down -v で戻せる"

PASS=0
FAIL=0

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing dependency: $1"
    exit 2
  }
}

# $1=期待する判定(pass|ask|deny) $2=ラベル $3=コマンド $4=サンドボックス外指定(既定 false)
# $5=description(既定 空)。承認を要する経路では 80 バイト以上ないと deny になる
assert_decision() {
  local expected="$1" label="$2" command="$3" escape="${4:-false}" description="${5:-}"
  local payload got
  payload=$(jq -cn --arg c "${command}" --arg d "${description}" --argjson e "${escape}" \
    '{tool_input: {command: $c, description: $d, dangerouslyDisableSandbox: $e}}')
  got=$(printf '%s' "${payload}" | bash "${GUARD}" 2>/dev/null |
    jq -r '.hookSpecificOutput.permissionDecision // empty' 2>/dev/null)
  # 何も返さない = 素通り
  [[ -z "${got}" ]] && got=pass
  if [[ "${got}" == "${expected}" ]]; then
    echo "  ok: ${label} (${got})"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: ${label} (expected=${expected} actual=${got})"
    FAIL=$((FAIL + 1))
  fi
}

require jq
[[ -f "${GUARD}" ]] || {
  echo "guard not found: ${GUARD}"
  exit 2
}

echo "case 1: 日常のビルド・テストは素通りする"
assert_decision pass "go test" 'go test ./... -count=1'
assert_decision pass "gofmt" 'gofmt -l .'
assert_decision pass "golangci-lint" 'golangci-lint run ./...'
assert_decision pass "通常の push" 'git push origin feature/x'
assert_decision pass "git -C は無害なので通す" 'git -C /tmp/repo status'
assert_decision pass "ループ内の gh pr list" 'for r in a b; do gh pr list -R o/$r; done'
assert_decision pass "gh api の GET" 'gh api repos/o/r/pulls'
assert_decision pass "gh repo view" 'gh repo view foo/bar'

echo "case 2: force push はフラグの位置を問わず deny"
assert_decision deny "先頭に --force" 'git push --force origin master'
assert_decision deny "末尾に --force" 'git push origin master --force'
assert_decision deny "末尾に -f" 'git push origin master -f'
assert_decision deny "git -C 経由" 'git -C /r push --force'
assert_decision pass "--force-with-lease は許可" 'git push --force-with-lease origin master'

echo "case 3: 作業ツリー・履歴の破壊は deny"
assert_decision deny "reset --hard" 'git reset --hard HEAD~1'
assert_decision deny "reset --hard 引数なし" 'git reset --hard'
assert_decision pass "reset (soft)" 'git reset HEAD~1'
assert_decision pass "reset --soft" 'git reset --soft HEAD~1'
assert_decision deny "clean -fd" 'git clean -fd'
assert_decision deny "clean --force" 'git clean --force -d'
assert_decision pass "clean -n は dry-run" 'git clean -n'
assert_decision deny "filter-repo" 'git filter-repo --path x'
assert_decision deny "filter-branch" 'git filter-branch --tree-filter x HEAD'
assert_decision deny "gh repo delete" 'gh repo delete foo/bar'

echo "case 4: サンドボックス外実行と認証情報の扱いは ask"
assert_decision ask "サンドボックス外" 'go test ./...' true "${DESC_OK}"
assert_decision ask "gh auth token の埋め込み" 'GH_TOKEN=$(gh auth token) zizmor .'
assert_decision ask "gh secret set" 'gh secret set FOO --body bar'
assert_decision ask "gh api の書き込み" 'gh api -X DELETE repos/o/r/x'
assert_decision ask "git -c" 'git -c core.pager=sh log'
assert_decision ask "GIT_SSH_COMMAND" 'GIT_SSH_COMMAND=x git fetch'
assert_decision ask "--upload-pack" 'git fetch origin --upload-pack=evil'

echo "case 5: ヒアドキュメント本文は実行対象ではないので検査しない"
assert_decision pass "本文に force フラグ" \
  $'cat > $TMPDIR/m.txt <<\'EOF\'\nfeat: force push を禁止する\ngit push origin master --force を捕まえる\nEOF\ngit commit -F $TMPDIR/m.txt'
assert_decision pass "本文に reset --hard" \
  $'python3 - <<\'PY\'\n# git reset --hard の説明\nPY'
assert_decision deny "本文の後ろにある本物の force push" \
  $'cat > $TMPDIR/m.txt <<\'EOF\'\n説明文\nEOF\ngit push --force origin main'

echo "case 6: 引数の切り出しは区切りをまたがない"
assert_decision pass "他コマンドの -f は force ではない" 'git push origin main && grep -f patterns.txt log'
assert_decision deny "本物の force + 他コマンドの -f" 'git push origin main --force && grep -f patterns.txt log'
assert_decision pass "コミットメッセージ内の言及" 'git commit -m "docs: --force の危険性を書く"'

echo "case 7: 解析できない入力は fail-closed で ask"
got=$(printf 'not json at all' | bash "${GUARD}" 2>/dev/null |
  jq -r '.hookSpecificOutput.permissionDecision // empty' 2>/dev/null)
if [[ "${got}" == "ask" ]]; then
  echo "  ok: 壊れた入力 (ask)"
  PASS=$((PASS + 1))
else
  echo "  FAIL: 壊れた入力 (expected=ask actual=${got:-none})"
  FAIL=$((FAIL + 1))
fi

# 承認ダイアログに出るのは description だけなので、説明が薄いまま承認を求めるのを
# 止める。deny なのは理由がモデルに返り、説明を書き直させられるためである。
# 対象は実際に承認を要する経路に限る。サンドボックス内で完結するコマンドは
# 自動許可でプロンプトが出ないので、ここで縛ると摩擦だけが増える。
echo "case 8: 承認を要する経路は説明が無いと deny"
assert_decision deny "サンドボックス外・説明なし" 'go test ./...' true
assert_decision deny "サンドボックス外・説明が短い" 'go test ./...' true 'テスト実行'
assert_decision ask "サンドボックス外・説明が十分" 'go test ./...' true "${DESC_OK}"
assert_decision deny "docker exec・説明が短い" 'docker exec -i pg-1 psql -c "select 1"' false 'DB確認'
assert_decision pass "docker exec・説明が十分" 'docker exec -i pg-1 psql -c "select 1"' false "${DESC_OK}"
assert_decision deny "docker compose exec・説明が短い" 'docker compose exec -T db psql' false '確認'
assert_decision deny "docker compose up -d・説明が短い" 'docker compose up -d' false '起動'
assert_decision deny "docker cp・説明が短い" 'docker cp ./x.sql pg-1:/tmp/x.sql' false '転送'

echo "case 9: 読み取り専用とサンドボックス内は説明を求めない"
assert_decision pass "docker ps" 'docker ps --format json'
assert_decision pass "docker compose ps" 'docker compose ps'
assert_decision pass "docker logs" 'docker logs pg-1 --tail 20'
assert_decision pass "サンドボックス内の npm run" 'npm run test:integration 2>&1 | tail -50'
assert_decision pass "サンドボックス内の go test" 'go test ./... -count=1'
# 単語の一部を拾わないこと。execute や runner は exec / run ではない
assert_decision pass "docker という語を含むだけの文字列" 'grep -rn docker-compose.yml .'

echo "case 10: 閾値は 80 バイト。境界を跨ぐところで判定が変わる"
DESC_79=$(printf 'a%.0s' $(seq 1 79))
DESC_80=$(printf 'a%.0s' $(seq 1 80))
assert_decision deny "79 バイト" 'go test ./...' true "${DESC_79}"
assert_decision ask "80 バイト" 'go test ./...' true "${DESC_80}"

echo "case 11: 破壊的操作の deny は説明の有無より優先する"
assert_decision deny "force push は説明があっても deny" 'git push --force origin main' false "${DESC_OK}"
assert_decision deny "reset --hard は説明があっても deny" 'git reset --hard HEAD~1' false "${DESC_OK}"

echo
echo "pass=${PASS} fail=${FAIL}"
[[ "${FAIL}" -eq 0 ]]
