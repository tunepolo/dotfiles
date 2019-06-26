autoload -U promptinit
promptinit

# zplugの初期設定
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

# zplugをzplugで管理
zplug 'zplug/zplug', hook-build:'zplug --self-manage'

# コマンドプロンプトの設定
zplug "mafredri/zsh-async", from:github
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme

# プラグインのインストール・設定
zplug "chrissicool/zsh-256color"
zplug "plugins/docker-compose", from:oh-my-zsh, defer:2, if:"(( $+commands[docker-compose] ))"
zplug "rupa/z", use:"*.sh"
zplug "simonwhitaker/gibo", use:'gibo-completion.zsh', as:plugin, if:"(( $+commands[gibo] ))", defer:2
zplug "zsh-users/zsh-syntax-highlighting"

# 補完設定
zplug "zsh-users/zsh-completions"
zplug "lukechilds/zsh-better-npm-completion", defer:2

# CLIツールのインストール・設定
zplug "paulirish/git-open", as:plugin

# 未インストール項目をインストールする
zplug check --verbose || zplug install
zplug load

# alias設定
[ -f ~/dotfiles/zsh/alias.zsh ] && source ~/dotfiles/zsh/alias.zsh

# オプション・カスタマイズ設定
[ -f ~/dotfiles/zsh/custom.zsh ] && source ~/dotfiles/zsh/custom.zsh

# OS毎の設定
case "${OSTYPE}" in
cygwin*)
	# Cygwin(Windows)
	[ -f ~/dotfiles/zsh/cygwin.zsh ] && source ~/dotfiles/zsh/cygwin.zsh
	;;
darwin*)
	# Mac(Unix)
	[ -f ~/dotfiles/zsh/osx.zsh ] && source ~/dotfiles/zsh/osx.zsh
	;;
linux*)
	# Linux
	[ -f ~/dotfiles/zsh/linux.zsh ] && source ~/dotfiles/zsh/linux.zsh
	;;
esac

# Set GOPATH for Go
if command -v go &>/dev/null; then
	[ -d "$HOME/.go" ] || mkdir "$HOME/.go"
	export GOPATH="$HOME/.go"
	export GOROOT=/usr/local/opt/go/libexec
	export PATH="$PATH:$GOPATH/bin:$GOROOT/bin"
fi

# Load rbenv
if [ -e "$HOME/.rbenv" ]; then
	export PATH="$HOME/.rbenv/bin:$PATH"
	eval "$(rbenv init -)"
fi

# Load phpenv
if [ -e "$HOME/.phpenv" ]; then
	export PATH="$HOME/.phpenv/bin:$PATH"
	eval "$(phpenv init -)"
fi

# Load direnv
if type direnv >/dev/null 2>&1; then
	eval "$(direnv hook zsh)"
fi

## local固有設定を読み込み
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
