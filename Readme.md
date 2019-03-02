# 使い方
```bash
$ git clone --recursive https://github.com/tunepolo/dotfiles.git
$ cd dotfiles
$ ./setup.sh
```

vimを起動する前にNeoBundleをインストールしておく。
```bash
$ git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
```
vimを起動したら`:NeoBundleInstall`を実行する。


# 設定ファイル

* git
    * .gitconfig
    * .global_ignore
* .inputrc
* .irbrc
* .minttyrc
* .pryrc
* .screenrc
* .tigrc
* .tmux.conf
* vim
    * .vimrc
    * .gvimrc
* zsh
    * .zshenv
    * .zshrc

## 固有の設定

下記の名称のローカルファイルを作ってそこに書くこと。

* .gitconfig.local
* .vimrc.local
* .zshrc.local

gitのユーザ名、プロキシ設定は~/.gitconfig.localに記述すること。1.7.10以降のバージョンのgitが必要。
