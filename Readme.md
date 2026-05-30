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
# 実行中に `email` と `name` を対話的に入力する（git config の [user] に反映される）
chezmoi init --apply https://github.com/tunepolo/dotfiles.git

# ツール・アプリケーションのインストール
# Mac App Store アプリ（Bitwarden, iMovie 等）が含まれるため、
# 事前に App Store にサインインしておく
brew bundle --global

# 追加のセットアップスクリプト実行（nvm、npm、macOS設定等）
# diff-highlight の symlink 作成で sudo パスワードが必要
cd ~/.local/share/chezmoi
./setup.sh
```

zsh プラグインは [sheldon](https://github.com/rossmacarthur/sheldon) で管理しており、設定は `~/.config/sheldon/plugins.toml`。初回シェル起動時にプラグインが自動的にcloneされる。

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

VSCode 組み込みの Settings Sync（GitHubアカウント連携）で同期する。

- [Settings Sync in Visual Studio Code（公式ドキュメント）](https://code.visualstudio.com/docs/configure/settings-sync)
