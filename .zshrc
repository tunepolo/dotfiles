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
