[![ShellCheck](https://github.com/tunepolo/dotfiles/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/tunepolo/dotfiles/actions/workflows/shellcheck.yml)

# 使い方

## chezmoiを使った設定管理（推奨）

### 初回セットアップ

```bash
# chezmoiのインストール
brew install chezmoi

# dotfilesリポジトリをcloneして初期化
chezmoi init https://github.com/tunepolo/dotfiles.git

# 設定ファイルの差分確認
chezmoi diff

# 設定ファイルを適用
chezmoi apply -v
```

### 設定の更新

```bash
# 最新の設定を取得して適用
chezmoi update -v

# 設定ファイルを編集
chezmoi edit ~/.zshrc

# 設定を再適用
chezmoi apply -v
```

## 従来の方法（setup.sh）

**注意**: setup.shは将来的に非推奨となる予定です。新規環境ではchezmoiの使用を推奨します。

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