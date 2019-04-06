# 使い方

## 設定ファイルの配置

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

## Homebrewを使ったツール・アプリケーションのインストール

```bash
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
$ cd dotfiles
$ brew bundle
```

## 詳細設定

### PC固有設定

下記の名称のローカルファイルを作ってそこに書くこと。

* .gitconfig.local
* .vimrc.local
* .zshrc.local

XXenv系の設定、ZPLUG_HOMEの設定は~/.zshrc.localに記述する。

```.zshrc.local
# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# zplug
export ZPLUG_HOME=/usr/local/opt/zplug
```

gitのユーザ名、認証設定、プロキシ設定は~/.gitconfig.localに記述する。

```.gitconfig.local
[user]
  name = Yuichi TSUNEMATSU
  email = tunepolo@gmail.com
[credential]
  helper = osxkeychain
```

### Visual Studio Codeの設定

Setting Sync拡張で設定を取得する。

* [VSCode(Visual Studio Code)の設定を同期させる拡張機能「Setting Sync」が便利 | カレリエ](https://www.karelie.net/vscode-setting-sync/#vscodesetting_sync-7)
