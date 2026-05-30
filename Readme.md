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

`chezmoi init` の際に対話的に入力するユーザー名・メールアドレスは
chezmoi data に保存され、`~/.config/git/config` の `[user]` セクションに
テンプレート展開で反映される。

さらにPC固有の設定を追加したい場合、下記のローカルファイルを作成できる：

* `~/.gitconfig.local` — 認証情報・プロキシ等。git config の末尾で
  `[include]` されるため、テンプレート側の設定も上書きできる
* `~/.vimrc.local`
* `~/.zshrc.local`

```.gitconfig.local
[credential]
  helper = osxkeychain
```

ユーザー名・メールアドレスを変更したい場合は `chezmoi edit-config` で
chezmoi data を編集し、`chezmoi apply` を再実行する。

### Visual Studio Codeの設定

GitHubでログインして同期する。

- [Visual Studio Code公式の設定同期を利用する - Qiita](https://qiita.com/Nuits/items/6204a6b0576b7a4e37ea)
