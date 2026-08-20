#!/usr/bin/env bash
# PreToolUse gate for the Bash tool.
#
# Why a script instead of an inline one-liner: the checks below must look for a
# flag anywhere in the command, not only right after `git`. Prefix patterns in
# permissions.deny cannot do that (`git push origin master --force` matches no
# `Bash(git push --force *)` rule), so the real gate lives here.
#
#   deny — irreversible history/worktree destruction
#   ask  — sandbox escapes, credential reads, write-mode API calls
#
# Fails closed: if the payload cannot be parsed, ask.

set -uo pipefail

emit() { # $1=decision $2=reason
  if command -v jq >/dev/null 2>&1; then
    jq -cn --arg d "$1" --arg r "$2" \
      '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:$d,permissionDecisionReason:$r}}'
  else
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":"%s"}}' "$1" "$2"
  fi
  exit 0
}

command -v jq >/dev/null 2>&1 || emit ask "jq が見つからず Bash ガードを評価できません"

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty') ||
  emit ask "フック入力の解析に失敗しました"
escape=$(printf '%s' "$input" | jq -r '.tool_input.dangerouslyDisableSandbox // false')

# ヒアドキュメントの本文は実行されるコマンドではないので検査対象から外す。
# 含めたままにすると、コミットメッセージやドキュメントに書いた
# "git push --force" のような文字列で誤検知する。終端行までを落とし、
# `<<EOF` を含む行そのものは残す。
if command -v perl >/dev/null 2>&1; then
  stripped=$(printf '%s' "$cmd" |
    perl -0777 -pe 's/(<<-?\s*(["\x27]?)(\w+)\2)(.*?)^[ \t]*\3[ \t]*$/$1/msg' 2>/dev/null)
  [ -n "$stripped" ] && cmd=$stripped
fi

has() { printf '%s' "$cmd" | grep -Eq "$1"; }

# サブコマンドが実際に git/gh の呼び出しになっているか。`git -C path push` や
# `$(gh auth token)` のような形も拾い、文字列として言及しただけの場合は拾わない。
git_sub() { has "(^|[^[:alnum:]_-])git([[:space:]]+(-C|-c)[[:space:]]+[^[:space:]]+)*[[:space:]]+$1([^[:alnum:]_-]|$)"; }
gh_sub() { has "(^|[^[:alnum:]_-])gh[[:space:]]+$1([^[:alnum:]_-]|$)"; }

# 指定した git サブコマンドの「引数部分だけ」を取り出す。区切り（; | & 改行）で
# 切るので、`git push origin main && grep -f x` の `-f` を force と誤認しない。
# perl が無い環境ではコマンド全体を返す（過剰に deny 側へ倒す）。
PERL_OK=false
command -v perl >/dev/null 2>&1 && PERL_OK=true
git_args() {
  if [ "$PERL_OK" = true ]; then
    printf '%s' "$cmd" | SUB="$1" perl -0777 -ne '
      my $s = quotemeta($ENV{SUB});
      while (/(?:^|[^\w-])git(?:\s+-[cC]\s+\S+)*\s+$s(?![\w-])([^\n;|&]*)/g) { print "$1\n" }'
  else
    printf '%s' "$cmd"
  fi
}
in_args() { printf '%s' "$(git_args "$1")" | grep -Eq "$2"; }

# ---- deny: 取り返しがつかない操作。オプションの位置に依存しない ----
# --force-with-lease は末尾が続くのでこの条件には当たらない
if in_args push '(^|[[:space:]])(--force|-f)([[:space:]]|$)'; then
  emit deny "force push は禁止です。--force-with-lease を使うか、人手で実行してください"
fi
if in_args reset '(^|[[:space:]])--hard([[:space:]]|$)'; then
  emit deny "git reset --hard は作業ツリーを破壊するため禁止です"
fi
if in_args clean '(^|[[:space:]])(--force|-[a-zA-Z]*f[a-zA-Z]*)([[:space:]]|$)'; then
  emit deny "git clean -f は未追跡ファイルを消すため禁止です"
fi
if git_sub filter-repo || git_sub filter-branch; then
  emit deny "履歴の書き換えは禁止です"
fi
gh_sub 'repo[[:space:]]+delete' && emit deny "リポジトリの削除は禁止です"

# ---- ask: サンドボックス外実行 ----
[ "$escape" = "true" ] &&
  emit ask "サンドボックス外実行には承認が必要です。一時ファイルは /tmp ではなく \$TMPDIR を使い、git/gh はビルドやテストと同じコマンドに混ぜないでください"

# ---- ask: 認証情報・書き込み系 API ----
gh_sub 'auth[[:space:]]+token' && emit ask "認証トークンの取り出しには承認が必要です"
gh_sub '(secret|variable)[[:space:]]+(set|delete)' &&
  emit ask "リポジトリのシークレット/変数の変更には承認が必要です"
if gh_sub api && has '(-X|--method)[[:space:]=]+(POST|PUT|PATCH|DELETE)'; then
  emit ask "gh api による書き込み操作には承認が必要です"
fi

# ---- ask: git の実行経路を差し替える指定 ----
has '(^|[[:space:]])(--upload-pack|--receive-pack|--exec-path)(=|[[:space:]]|$)' &&
  emit ask "git の実行経路を差し替えるオプションです"
has '(^|[[:space:]])(GIT_SSH_COMMAND=|GIT_CONFIG_[A-Za-z_]*=)' &&
  emit ask "git の実行経路を差し替える環境変数です"
# `git -c` は任意コマンドを仕込めるので ask。`git -C` は作業ディレクトリを変えるだけなので通す。
has '(^|[^[:alnum:]_-])git[[:space:]]+-c([[:space:]]|=)' &&
  emit ask "git -c は設定を上書きして任意コマンドを実行できます"

exit 0
