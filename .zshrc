autoload -U promptinit; promptinit

# zplugの初期設定
source $ZPLUG_HOME/init.zsh

# コマンドプロンプトの設定
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme

# プラグインのインストール・設定
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "rupa/z", use:"*.sh"

# CLIツールのインストール・設定
zplug "paulirish/git-open", as:plugin

# 未インストール項目をインストールする
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# コマンドをリンクして、PATH に追加し、プラグインは読み込む
zplug load

# alias設定
[ -f ~/dotfiles/.zshrc.alias ] && source ~/dotfiles/.zshrc.alias

# ls 時の色を設定する
export CLICOLOR=true
export LSCOLORS='exfxcxdxbxGxDxabagacad'
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'

# オプション設定
setopt always_last_prompt    # カーソル位置は保持したままファイル名一覧を順次その場で表示
setopt append_history
setopt auto_cd               # ディレクトリと解釈できる文字列を打てばcdできる
setopt auto_list             # 補完候補が複数ある時に、一覧表示
setopt auto_menu             # 補完キー連打で順に補完候補を自動で補完
setopt auto_name_dirs
setopt auto_param_keys       # カッコの対応などを自動的に補完
setopt auto_param_slash      # ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt auto_pushd
setopt auto_remove_slash
setopt auto_resume
setopt bang_hist
setopt bg_nice
setopt cd_able_vars
setopt cdable_vars
setopt chase_links
setopt check_jobs
setopt complete_in_word      # 語の途中でもカーソル位置で補完
setopt correct
setopt correct_all
setopt equals
setopt extended_glob         # 拡張グロブで補完(~とか^とか。例えばless *.txt~memo.txt ならmemo.txt 以外の *.txt にマッチ)
setopt extended_history
setopt glob_dots
setopt globdots              # 明確なドットの指定なしで.から始まるファイルをマッチ
setopt hist_beep
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_no_store
setopt hist_reduce_blanks
setopt ignore_eof
setopt inc_append_history
setopt interactive_comments  # コマンドラインでも # 以降をコメントと見なす
setopt list_packed
setopt list_types            # 補完候補一覧でファイルの種別を識別マーク表示 (訳注:ls -F の記号)
setopt long_list_jobs
setopt magic_equal_subst     # コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
setopt mark_dirs             # ファイル名の展開でディレクトリにマッチした場合 末尾に / を付加
setopt no_beep
setopt no_list_beep
setopt notify
setopt notify
setopt numeric_glob_sort
setopt print_eight_bit       # 日本語ファイル名等8ビットを通す
setopt prompt_subst
setopt pushd_ignore_dups
setopt pushd_silent
setopt sh_word_split
setopt share_history
setopt sun_keyboard_hack
setopt transient_rprompt

# Enterキーでlsとgit statusを実行する
# http://qiita.com/yuyuchu3333/items/e9af05670c95e2cc5b4d
function do_enter() {
    if [ -n "$BUFFER" ]; then
        zle accept-line
        return 0
    fi
    echo
    ls -a
    # ↓おすすめ
    # ls_abbrev
    if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = 'true' ]; then
        echo
        echo -e "\e[0;33m--- git status ---\e[0m"
        git status -sb
        echo
    fi
    zle reset-prompt
    return 0
}
zle -N do_enter
bindkey '^m' do_enter

# OS毎の設定
case "${OSTYPE}" in
cygwin*)
	# Cygwin(Windows)
	[ -f ~/dotfiles/.zshrc.cygwin ] && source ~/dotfiles/.zshrc.cygwin
	;;
darwin*)
	# Mac(Unix)
	[ -f ~/dotfiles/.zshrc.osx ] && source ~/dotfiles/.zshrc.osx
	;;
linux*)
	# Linux
	[ -f ~/dotfiles/.zshrc.linux ] && source ~/dotfiles/.zshrc.linux
	;;
esac

## local固有設定を読み込み
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
