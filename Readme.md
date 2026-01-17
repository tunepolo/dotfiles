[![ShellCheck](https://github.com/tunepolo/dotfiles/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/tunepolo/dotfiles/actions/workflows/shellcheck.yml)

# 使い方

## 設定ファイルの配置

```bash
$ git clone https://github.com/tunepolo/dotfiles.git
$ cd dotfiles
$ ./setup.sh
```

## Homebrewを使ったツール・アプリケーションのインストール

```bash
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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

GitHubでログインして同期する。

- [Visual Studio Code公式の設定同期を利用する - Qiita](https://qiita.com/Nuits/items/6204a6b0576b7a4e37ea)