autoload -U promptinit; promptinit

# zplugの初期設定
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

# コマンドプロンプトの設定
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme

# プラグインのインストール・設定
zplug "chrissicool/zsh-256color"
zplug "rupa/z", use:"*.sh"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting"

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

# ls 時の色を設定する
export CLICOLOR=true
export LSCOLORS='exfxcxdxbxGxDxabagacad'
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'

# alias設定
[ -f ~/dotfiles/.zshrc.alias ] && source ~/dotfiles/.zshrc.alias

# オプション設定
[ -f ~/dotfiles/.zshrc.setopt ] && source ~/dotfiles/.zshrc.setopt

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
