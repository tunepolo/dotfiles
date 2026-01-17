#!/bin/zsh
# shellcheck shell=bash
#====================================================================
# Setting Options
#====================================================================
setopt always_last_prompt   # カーソル位置は保持したままファイル名一覧を順次その場で表示
setopt append_history       # 毎回 .zsh_history を作るのではなく履歴を追加
setopt auto_cd              # ディレクトリと解釈できる文字列を打てばcdできる
setopt auto_list            # 補完候補が複数ある時に、一覧表示
setopt auto_menu            # 補完キー連打で順に補完候補を自動で補完
setopt auto_name_dirs       # "~$var" でディレクトリにアクセス
setopt auto_param_keys      # カッコの対応などを自動的に補完
setopt auto_param_slash     # ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt auto_pushd           # ディレクトリ移動時に元のディレクトリを自動でスタックに積む
setopt auto_remove_slash    # 補完で補われたスラッシュが状況に応じてが自動的に削除される
setopt auto_resume          # サスペンド中のプロセスと同じコマンド名を実行した場合はリジュームする
setopt bang_hist            # cshスタイルのヒストリ拡張を使う
setopt bg_nice              # バックグラウンドジョブの優先度を下げる(0->5)
setopt cd_able_vars         #
setopt chase_links          # シンボリックリンクは実体を追うようになる
setopt check_jobs           # zsh終了時に、バックグラウンドジョブや停止中のジョブを表示する
setopt complete_in_word     # 語の途中でもカーソル位置で補完
setopt correct              # コマンドのスペルチェックをする
setopt correct_all          # コマンドライン全てのスペルチェックをする
setopt equals               #
setopt extended_glob        # 拡張グロブで補完(~とか^とか。例えばless *.txt~memo.txt ならmemo.txt 以外の *.txt にマッチ)
setopt extended_history     #
setopt globdots             # 明確なドットの指定なしで.から始まるファイルをマッチ
setopt hist_beep            #
setopt hist_find_no_dups    #
setopt hist_ignore_all_dups #
setopt hist_ignore_dups     #
setopt hist_ignore_space    # スペース始まりのコマンドは履歴に含めない
setopt hist_no_store        #
setopt hist_reduce_blanks   # 余分な空白は詰める
setopt ignore_eof           #
setopt inc_append_history   # コマンド実行時にヒストリに追加
setopt interactive_comments # コマンドラインでも # 以降をコメントと見なす
setopt list_packed          # 補完候補リストを詰めて表示
setopt list_types           # 補完候補一覧でファイルの種別を識別マーク表示 (訳注:ls -F の記号)
setopt long_list_jobs       #
setopt magic_equal_subst    # コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
setopt mark_dirs            # ファイル名の展開でディレクトリにマッチした場合 末尾に / を付加
setopt no_beep              #
setopt no_list_beep         # beepを鳴らさないようにする
setopt notify               #
setopt numeric_glob_sort    #
setopt print_eight_bit      # 日本語ファイル名等8ビットを通す
setopt prompt_subst         #
setopt pushd_ignore_dups    # ディレクトリスタックに同じディレクトリを追加しない
setopt pushd_silent         #
setopt sh_word_split        #
setopt share_history        #
setopt sun_keyboard_hack    #
setopt transient_rprompt    #

#====================================================================
# 補完
#====================================================================

autoload -U compinit
compinit
zstyle ':completion:*:default' menu select=1

# npm completion

###-begin-npm-completion-###
# shellcheck disable=SC2207,SC2046,SC2034,SC2162,SC2219
#
# npm command completion script
#
# Installation: npm completion >> ~/.bashrc  (or ~/.zshrc)
# Or, maybe: npm completion > /usr/local/etc/bash_completion.d/npm
#

if type complete &>/dev/null; then
  _npm_completion() {
    local words cword
    if type _get_comp_words_by_ref &>/dev/null; then
      _get_comp_words_by_ref -n = -n @ -n : -w words -i cword
    else
      cword="$COMP_CWORD"
      words=("${COMP_WORDS[@]}")
    fi

    local si="$IFS"
    IFS=$'\n' COMPREPLY=($(COMP_CWORD="$cword" \
      COMP_LINE="$COMP_LINE" \
      COMP_POINT="$COMP_POINT" \
      npm completion -- "${words[@]}" \
      2>/dev/null)) || return $?
    IFS="$si"
    if type __ltrim_colon_completions &>/dev/null; then
      __ltrim_colon_completions "${words[cword]}"
    fi
  }
  complete -o default -F _npm_completion npm
elif type compdef &>/dev/null; then
  _npm_completion() {
    local si=$IFS
    compadd -- $(COMP_CWORD=$((CURRENT - 1)) \
      COMP_LINE=$BUFFER \
      COMP_POINT=0 \
      npm completion -- "${words[@]}" \
      2>/dev/null)
    IFS=$si
  }
  compdef _npm_completion npm
elif type compctl &>/dev/null; then
  _npm_completion() {
    local cword line point words si
    read -Ac words
    read -cn cword
    let cword-=1
    read -l line
    read -ln point
    si="$IFS"
    IFS=$'\n' reply=($(COMP_CWORD="$cword" \
      COMP_LINE="$line" \
      COMP_POINT="$point" \
      npm completion -- "${words[@]}" \
      2>/dev/null)) || return $?
    IFS="$si"
  }
  compctl -K _npm_completion npm
fi
###-end-npm-completion-###

# AWS CLI
# shellcheck disable=SC1091
[ -f /usr/local/share/zsh/site-functions/aws_zsh_completer.sh ] && source /usr/local/share/zsh/site-functions/aws_zsh_completer.sh

#====================================================================
# Keybinding
#====================================================================
bindkey -v

bindkey '^R' history-incremental-pattern-search-backward
bindkey '^S' history-incremental-pattern-search-forward

#====================================================================
# その他カスタマイズ
#====================================================================

# ls 時の色を設定する
export CLICOLOR=true
export LSCOLORS='exfxcxdxbxGxDxabagacad'
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'

# 256色表示できているかの確認用
function 256colortest() {
  local code
  for code in {0..255}; do
    echo -e "\e[38;05;${code}m $code: Test"
  done
}

# Go modulesをmodule-aware modeで使用する
export GO111MODULE=auto
