#====================================================================
# Setting Alias
#====================================================================
alias ls='lsd -aF'
alias ll='ls -l'
alias la='ls -a'
alias grep='grep --color=always'
alias j=jobs
alias so="source ~/.zshrc"
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
alias vi=vim

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

