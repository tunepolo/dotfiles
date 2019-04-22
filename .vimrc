" neobunlde.vimで管理してるpluginを読み込む
source ~/dotfiles/vim/.vimrc.bundle

" 基本設定
source ~/dotfiles/vim/.vimrc.basic

" 外観設定
source ~/dotfiles/vim/.vimrc.appearance
source ~/dotfiles/vim/.vimrc.tab

" プラグイン設定
source ~/dotfiles/vim/.vimrc.plugin_setting

" ローカル設定
if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif

