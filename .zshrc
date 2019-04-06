autoload -U promptinit; promptinit

# zplugの初期設定
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

# コマンドプロンプトの設定
zplug "mafredri/zsh-async", from:github
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

# alias設定
[ -f ~/dotfiles/.zshrc.alias ] && source ~/dotfiles/.zshrc.alias

# オプション・カスタマイズ設定
[ -f ~/dotfiles/.zshrc.custom ] && source ~/dotfiles/.zshrc.custom

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
