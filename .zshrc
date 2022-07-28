autoload -U promptinit
promptinit

# zplugの初期設定
export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh

# zplugをzplugで管理
zplug 'zplug/zplug', hook-build:'zplug --self-manage'

# プラグインのインストール・設定
zplug "chrissicool/zsh-256color"
zplug "plugins/docker-compose", from:oh-my-zsh, defer:2, if:"(( $+commands[docker-compose] ))"
zplug "rupa/z", use:"*.sh"
zplug "simonwhitaker/gibo", use:'gibo-completion.zsh', as:plugin, if:"(( $+commands[gibo] ))", defer:2
zplug "zsh-users/zsh-syntax-highlighting"

# 補完設定
zplug "zsh-users/zsh-completions", defer:0, use:contrib/completion/zsh
zplug "zsh-users/zsh-autosuggestions", defer:2
zplug "zsh-users/zsh-syntax-highlighting", defer:3
zplug "zsh-users/zsh-history-substring-search", defer:3
zplug "lukechilds/zsh-better-npm-completion", defer:3, use:contrib/completion/zsh
zplug "felixr/docker-zsh-completion", defer:3, use:contrib/completion/zsh
zplug "zpm-zsh/ssh", defer:3, use:contrib/completion/zsh

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

# Load starship
eval "$(starship init zsh)"

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

# Load nvm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

autoload -U add-zsh-hook
load-nvmrc() {
	local node_version="$(nvm version)"
	local nvmrc_path="$(nvm_find_nvmrc)"

	if [ -n "$nvmrc_path" ]; then
		local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

		if [ "$nvmrc_node_version" = "N/A" ]; then
			nvm install
		elif [ "$nvmrc_node_version" != "$node_version" ]; then
			nvm use
		fi
	elif [ "$node_version" != "$(nvm version default)" ]; then
		echo "Reverting to nvm default version"
		nvm use default
	fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# Load pyenv
eval "$(pyenv init --path)"

# Load direnv
if type direnv >/dev/null 2>&1; then
	eval "$(direnv hook zsh)"
fi

## local固有設定を読み込み
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
