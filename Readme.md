[![CircleCI](https://circleci.com/gh/tunepolo/dotfiles.svg?style=svg)](https://circleci.com/gh/tunepolo/dotfiles)

# 使い方

## 設定ファイルの配置

```bash
$ git clone https://github.com/tunepolo/dotfiles.git
$ cd dotfiles
$ ./setup.sh
```

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
