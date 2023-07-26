
-- ################
-- ## Map Leader ##
-- ################
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- #####################
-- ## Package Manager ##
-- #####################
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ##############
-- ## Packages ##
-- ##############
require("lazy").setup({
  -- Auto manages indentation
  'tpope/vim-sleuth',
  'tpope/vim-fugitive',

  -- Keymap display
  { 'folke/which-key.nvim', opts = {} },

  -- Status Line
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        icons_enabled = false,
        theme = 'ayu_dark',
        component_separators = "|",
        section_separators = "",
      }
    } 
  },

  { "lukas-reineke/indent-blankline.nvim",
    opts = {
      char = '┊',
      show_trailing_blankline_indent = false,
    },
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },
  
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    dependencies = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},             -- Required
      {                                      -- Optional
        'williamboman/mason.nvim',
        build = function()
          pcall(vim.api.nvim_command, 'MasonUpdate')
        end,
      },
      {'williamboman/mason-lspconfig.nvim'}, -- Optional

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},     -- Required
      {'hrsh7th/cmp-nvim-lsp'}, -- Required
      {'L3MON4D3/LuaSnip'},     -- Required
    }
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  -- Theme
  { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false, priority = 1000 },
})

-- ##############
-- ## LSP Zero ##
-- ##############
local lsp = require('lsp-zero').preset({})

-- GDscript compatibility
require('lspconfig').gdscript.setup({})

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup()
-- vim.lsp.set_log_level("debug")


-- ################
-- ## TreeSitter ##
-- ################

require('nvim-treesitter.configs').setup({
  ensure_installed = { 'vimdoc', 'rust', 'lua', 'gdscript', 'python', 'c', 'cpp', 'dart', 'javascript', 'typescript' },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,

    disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
              return true
          end
      end,
  },
})


-- ###########
-- ## Theme ##
-- ###########
vim.cmd [[colorscheme moonfly]]

-- ##############
-- ## Keybinds ##
-- ##############
-- Vanilla
vim.keymap.set('n', '<leader>e', vim.cmd.Ex)

-- ##############
-- ## Settings ##
-- ##############
-- Set highlight on search
vim.o.hlsearch = false

-- Show line numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- ##########################################
-- ## Secrete Sauce i don't yet understand ##
-- ##########################################
--
-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

