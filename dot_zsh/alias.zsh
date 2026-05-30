#!/bin/zsh
# shellcheck shell=bash
#====================================================================
# Setting Alias
#====================================================================
alias ls='lsd -aF'
alias ll='ls -l'
alias la='ls -a'
alias grep='grep --color=auto'
alias j=jobs
alias so="source ~/.zshrc"
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
alias vi=vim

# sudo時にsudo_pathをPATHに加える（.zshenvではなくここで定義することで
# cmuxなど一部の環境でghostty-integrationのsudo()関数定義と衝突するのを避ける）
if [ "$(id -u)" -ne 0 ]; then
	# shellcheck disable=SC2139  # SUDO_PATH/PATHを定義時に展開して埋め込むのは意図通り
	alias sudo="sudo env PATH=\"$SUDO_PATH:$PATH\""
fi

#====================================================================
# Setting Extension Alias
# Usage:
# % ps aux G apache
#====================================================================
alias -g G='| grep '
alias -g L='| less '
alias -g H='| head '
alias -g T='| tail '
alias -g V='| vi '

#====================================================================
# Specific tool alias
#====================================================================
# for ghq
alias pcd='cd $(ghq list --full-path | fzf)'

