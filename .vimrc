" neobunlde.vimで管理してるpluginを読み込む
source ~/dotfiles/vim/bundle.vim

" 基本設定
source ~/dotfiles/vim/basic.vim

" 外観設定
source ~/dotfiles/vim/appearance.vim
source ~/dotfiles/vim/tab.vim

" プラグイン設定
source ~/dotfiles/vim/plugin_setting.vim

" ローカル設定
if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif

