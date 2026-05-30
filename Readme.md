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

Ruby / Python / Node 等のバージョン管理は [mise](https://mise.jdx.dev/) で統合している。リポジトリごとに `.tool-versions` / `.node-version` 等を置けば `cd` した瞬間に自動で切り替わる。グローバル版を入れたい場合：

```bash
mise use --global node@lts ruby@latest python@latest
```

エディタは Neovim を使用。設定は `~/.config/nvim/` 配下に集約：

- `init.lua` — 全般オプション・キーマップ・autocmd
- `lua/plugins.lua` — [lazy.nvim](https://github.com/folke/lazy.nvim) のプラグイン宣言

初回 `nvim` 起動時に lazy.nvim が自動でブートストラップされ、続けてプラグインがインストールされる。

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

### Git コミット署名（SSH 鍵）

`~/.ssh/id_rsa.pub` を用いた SSH 鍵による署名がデフォルトで有効。
コミット時に自動的に署名される。

別のキーを使いたい場合は `~/.gitconfig.local` で上書き：

```.gitconfig.local
[user]
  signingkey = ~/.ssh/id_ed25519.pub
```

署名鍵は GitHub では **Authentication Key と別枠** で「Signing Key」として
登録する必要がある（GitHub 上で Verified バッジを付けるため）：
[Telling Git about your signing key – GitHub Docs](https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key#telling-git-about-your-ssh-key)

### SSH 鍵を Bitwarden SSH Agent で管理する

秘密鍵をディスクに置かず、Bitwarden Desktop の SSH Agent から提供する構成。
新PCへの移行時は Bitwarden にログインするだけで鍵が即使えるようになる。

`dot_zshenv` で `SSH_AUTH_SOCK` を Bitwarden のソケットに向けてあるので、
Bitwarden Desktop で agent を有効にしている間は ssh / git が自動で
Vault の鍵を使う（未起動ならシステム標準の agent にフォールバック）。

#### 既存鍵を Bitwarden に取り込む手順

1. Bitwarden Desktop を起動・ログイン
2. **+ Add item → SSH Key** で新規アイテムを作成し、`~/.ssh/id_rsa`（秘密鍵）と
   `~/.ssh/id_rsa.pub`（公開鍵）の中身を貼り付けて保存
3. **Settings → SSH agent → Enable SSH agent** を ON
4. シェルを開き直し、 `ssh-add -L` で公開鍵が表示されることを確認
5. テスト: `ssh -T git@github.com`、`git commit --allow-empty -m 'signing test'`
   で動作確認（コミット時に Bitwarden が承認ダイアログを出す）

#### 新PCセットアップ時の鍵復元

1. Bitwarden Desktop を入れてログイン → Settings → SSH agent を有効化
2. `chezmoi init --apply` で dotfiles を反映（`SSH_AUTH_SOCK` が自動設定される）
3. git 署名用に公開鍵をディスクに書き出し：
   ```bash
   mkdir -p ~/.ssh && chmod 700 ~/.ssh
   ssh-add -L > ~/.ssh/id_rsa.pub
   ```
4. 動作確認: `ssh -T git@github.com`

### Visual Studio Codeの設定

VSCode 組み込みの Settings Sync（GitHubアカウント連携）で同期する。

- [Settings Sync in Visual Studio Code（公式ドキュメント）](https://code.visualstudio.com/docs/configure/settings-sync)
