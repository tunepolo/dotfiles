-- ~/.config/nvim/lua/plugins.lua
-- 旧 dein.toml の lazy.nvim 移植版

return {
  --================================================================
  -- カラースキーム
  --================================================================
  {
    "tomasr/molokai",
    priority = 1000,
    lazy = false,
    config = function()
      vim.cmd.colorscheme("molokai")
      vim.g.molokai_original = 1
      vim.opt.background = "dark"
    end,
  },

  --================================================================
  -- ステータスライン（旧 lightline.vim）
  --================================================================
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "molokai",
        section_separators = "",
        component_separators = "|",
      },
    },
  },

  --================================================================
  -- インデントガイド（旧 vim-indent-guides）
  --================================================================
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPre",
    opts = { indent = { char = "▏" } },
  },

  --================================================================
  -- カッコの虹色（旧 rainbow_parentheses.vim）
  --================================================================
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPre",
  },

  --================================================================
  -- 行末空白を強調（旧 vim-bad-whitespace）
  --================================================================
  {
    "ntpeters/vim-better-whitespace",
    event = "BufReadPost",
  },

  --================================================================
  -- カッコ自動補完（旧 vim-smartinput）
  --================================================================
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },

  --================================================================
  -- テキスト操作
  --================================================================
  { "tpope/vim-surround", event = "BufReadPost" },                   -- 括弧で囲む
  { "junegunn/vim-easy-align", event = "BufReadPost" },              -- 整形

  --================================================================
  -- EditorConfig
  --================================================================
  { "editorconfig/editorconfig-vim", event = "BufReadPre" },

  --================================================================
  -- 検索位置表示（vim-anzu）
  --================================================================
  {
    "osyo-manga/vim-anzu",
    keys = { "n", "N", "*", "#" },
    init = function()
      vim.keymap.set("n", "n", "<Plug>(anzu-n-with-echo)zz")
      vim.keymap.set("n", "N", "<Plug>(anzu-N-with-echo)zz")
      vim.keymap.set("n", "*", "<Plug>(anzu-star-with-echo)zz")
      vim.keymap.set("n", "#", "<Plug>(anzu-sharp-with-echo)zz")
    end,
  },

  --================================================================
  -- j/k 加速（旧 accelerated-jk）
  --================================================================
  {
    "rhysd/accelerated-jk",
    keys = { "j", "k" },
    init = function()
      vim.keymap.set("n", "j", "<Plug>(accelerated_jk_gj)")
      vim.keymap.set("n", "k", "<Plug>(accelerated_jk_gk)")
    end,
  },

  --================================================================
  -- Git
  --================================================================
  { "tpope/vim-fugitive", cmd = { "Git", "Gstatus", "Gdiff", "Gblame" } },
  { "airblade/vim-gitgutter", event = "BufReadPost" },

  --================================================================
  -- GitHub Copilot
  --================================================================
  {
    "github/copilot.vim",
    event = "VeryLazy",
    init = function()
      vim.g.copilot_filetypes = { gitcommit = true }
    end,
  },
}
