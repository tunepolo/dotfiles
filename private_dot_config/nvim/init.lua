-- ~/.config/nvim/init.lua
-- 旧 ~/.vim/{basic,appearance,tab}.vim + dein.toml の lazy.nvim 移植版

--====================================================================
-- 基本設定
--====================================================================
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.autoread = true
vim.opt.showcmd = true
vim.opt.cmdheight = 2
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 16
vim.opt.sidescroll = 1
vim.opt.backspace = "indent,eol,start"
vim.opt.fileformats = "unix,dos,mac"
vim.opt.formatoptions:append("lmoq")
vim.opt.visualbell = true
vim.opt.belloff = "all"
vim.opt.whichwrap = "b,s,h,l,<,>,[,]"
vim.opt.clipboard:append("unnamedplus")
vim.opt.smoothscroll = true                 -- 旧 Smooth-Scroll プラグイン代替
vim.opt.timeout = false
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 200

--====================================================================
-- 検索
--====================================================================
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrapscan = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.grepprg = "grep -rnIH --exclude-dir=.svn --exclude-dir=.git"

--====================================================================
-- 表示
--====================================================================
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.list = true
vim.opt.listchars = { tab = ">.", trail = "_", extends = ">", precedes = "<" }
vim.opt.laststatus = 2
vim.opt.lazyredraw = true
vim.opt.ambiwidth = "double"
vim.opt.display = "uhex"
vim.opt.showmatch = true
vim.opt.textwidth = 0

--====================================================================
-- インデント（デフォルト：4 / hard tab）
--====================================================================
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- ファイルタイプ別の上書き
local ft_indent_group = vim.api.nvim_create_augroup("ft_indent", { clear = true })
local function ft_indent(filetypes, sw, et)
  vim.api.nvim_create_autocmd("FileType", {
    group = ft_indent_group,
    pattern = filetypes,
    callback = function()
      vim.opt_local.shiftwidth = sw
      vim.opt_local.softtabstop = sw
      vim.opt_local.tabstop = sw
      if et then vim.opt_local.expandtab = true end
    end,
  })
end
ft_indent({ "css", "html", "haml", "vim", "yaml", "scala" }, 2, true)
ft_indent({ "javascript", "ruby" }, 2, true)
ft_indent({ "apache", "c", "cpp", "cs", "diff", "eruby", "java", "perl",
            "php", "python", "sh", "sql", "xhtml", "xml", "zsh" }, 4, false)

--====================================================================
-- 全角スペース・行末空白のハイライト
--====================================================================
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.cmd([[
      highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=darkgray
      highlight WhitespaceEOL ctermbg=red guibg=red
    ]])
  end,
})
vim.fn.matchadd("ZenkakuSpace", "　")
vim.fn.matchadd("WhitespaceEOL", [[\s\+$]])

--====================================================================
-- キーマップ
--====================================================================
local map = vim.keymap.set

-- バッファ移動
map("n", "<F2>", "<ESC>:bp<CR>")
map("n", "<F3>", "<ESC>:bn<CR>")
map("n", "<F4>", "<ESC>:bw<CR>")

-- ESC×2 でハイライト消去
map("n", "<ESC><ESC>", ":nohlsearch<CR><ESC>")

-- 検索結果を画面中央に
for _, key in ipairs({ "n", "N", "*", "#" }) do
  map("n", key, key .. "zz")
end
map("n", "g*", "g*zz")
map("n", "g#", "g#zz")

-- タブページ移動
map("n", "<S-Tab>", "gt")
map("n", "<Tab><Tab>", "gT")
for i = 1, 9 do
  map("n", "<Tab>" .. i, i .. "gt")
end

--====================================================================
-- バイナリ編集モード（xxd）
--====================================================================
local bin_group = vim.api.nvim_create_augroup("BinaryXXD", { clear = true })
vim.api.nvim_create_autocmd("BufReadPre", {
  group = bin_group,
  pattern = "*.bin",
  callback = function() vim.opt_local.binary = true end,
})
vim.api.nvim_create_autocmd("BufReadPost", {
  group = bin_group,
  pattern = "*",
  callback = function()
    if vim.bo.binary then
      vim.cmd("silent %!xxd -g 1")
      vim.bo.filetype = "xxd"
    end
  end,
})
vim.api.nvim_create_autocmd("BufWritePre", {
  group = bin_group,
  pattern = "*",
  callback = function()
    if vim.bo.binary then vim.cmd("%!xxd -r") end
  end,
})
vim.api.nvim_create_autocmd("BufWritePost", {
  group = bin_group,
  pattern = "*",
  callback = function()
    if vim.bo.binary then
      vim.cmd("silent %!xxd -g 1")
      vim.bo.modified = false
    end
  end,
})

--====================================================================
-- lazy.nvim ブートストラップ
--====================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")
