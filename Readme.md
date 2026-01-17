[![ShellCheck](https://github.com/tunepolo/dotfiles/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/tunepolo/dotfiles/actions/workflows/shellcheck.yml)

# 使い方

## chezmoiを使った設定管理（推奨）

### 初回セットアップ

```bash
# Homebrewのインストール（未インストールの場合）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# chezmoiのインストール
brew install chezmoi

# dotfilesリポジトリをcloneして設定ファイルを適用
chezmoi init --apply https://github.com/tunepolo/dotfiles.git

# ツール・アプリケーションのインストール
brew bundle --global

# 追加のセットアップスクリプト実行（nvm、npm、macOS設定等）
cd ~/.local/share/chezmoi
./setup.sh
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

## 詳細設定

### PC固有設定

chezmoi initの際に、ユーザー名とメールアドレスが対話的に設定されます。
また、下記の名称のローカルファイルを作成することで、PC固有設定を追加できます。

* ~/.gitconfig.local
* ~/.vimrc.local
* ~/.zshrc.local

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
