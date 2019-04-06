#====================================================================
# Settig Environment Variable
#====================================================================

export GOPATH=$HOME/.go
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
$GOPATH/bin(N-/)
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

# lessの設定
## -R: ANSIエスケープシーケンスのみ素通しする。
export LESS="-R"

# エディタの設定
export EDITOR=vim

# 256色表示できているかの確認用
function 256colortest() {
local code
for code in {0..255}; do
	echo -e "\e[38;05;${code}m $code: Test"
done
}
