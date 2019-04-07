#====================================================================
# Settig Environment Variable
#====================================================================

export HISTFILE=$HOME/.zhistory
export HISTSIZE=100000
export LANG=ja_JP.UTF-8
export SAVEHIST=100000

# 重複したパスを登録しない。
typeset -U path

# (N-/): 存在しないディレクトリは登録しない。
#    パス(...): ...という条件にマッチするパスのみ残す。
#            N: NULL_GLOBオプションを設定。
#               globがマッチしなかったり存在しないパスを無視する。
#            -: シンボリックリンク先のパスを評価。
#            /: ディレクトリのみ残す。
path=(
/usr/local/bin(N-/)
/opt/local/bin(N-/)
/usr/bin(N-/)
/bin(N-/)
/usr/X11R6/bin(N-/)
$HOME/dotfiles/bin/*(N-/)
$HOME/bin(N-/)
)

# sudo時のパスの設定
# -x: export SUDO_PATHも一緒に行う。
# -T: SUDO_PATHとsudo_pathを連動する。
typeset -xT SUDO_PATH sudo_path
# 重複したパスを登録しない。
typeset -U sudo_path

# (N-/): 存在しないディレクトリは登録しない。
#    パス(...): ...という条件にマッチするパスのみ残す。
#            N: NULL_GLOBオプションを設定。
#               globがマッチしなかったり存在しないパスを無視する。
#            -: シンボリックリンク先のパスを評価。
#            /: ディレクトリのみ残す。
sudo_path=(
/sbin(N-/)
/usr/sbin(N-/)
/usr/local/sbin(N-/)
/opt/local/sbin(N-/)
)

if [ $(id -u) -eq 0 ]; then
	# rootの場合はsudo用のパスもPATHに加える。
	path=($sudo_path $path)
else
	# 一般ユーザーの場合はsudo時にsudo用のパスをPATHに加える。
	alias sudo="sudo env PATH=\"$SUDO_PATH:$PATH\""
fi

# Set GOPATH for Go
if command -v go &> /dev/null; then
  [ -d "$HOME/.go" ] || mkdir "$HOME/.go"
  export GOPATH="$HOME/.go"
  export GOROOT=/usr/local/opt/go/libexec
  export PATH="$PATH:$GOPATH/bin:$GOROOT/bin"
fi

# Load rbenv
if [ -e "$HOME/.rbenv" ]; then
  eval "$(rbenv init -)"
fi

# lessの設定
## -R: ANSIエスケープシーケンスのみ素通しする。
export LESS="-R"

# エディタの設定
export EDITOR=vim
