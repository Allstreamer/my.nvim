
-- ################
-- ## Map Leader ##
-- ################
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

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
  'Raimondi/delimitMate',

  {'nvim-tree/nvim-tree.lua', lazy = false},

  { 'echasnovski/mini.move', version = '*' },

  {
    'nvim-telescope/telescope.nvim', tag = '0.1.2',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

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
  'milisims/nvim-luaref',
})

-- ##############
-- ## LSP Zero ##
-- ##############
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

-- GDscript compatibility
require('lspconfig').gdscript.setup({
  cmd = {'nc', '127.0.0.1', '6005'},
})

lsp.setup()

-- ################
-- ## TreeSitter ##
-- ################

require('nvim-treesitter.configs').setup({
  ensure_installed = { 'vimdoc', 'lua', 'gdscript', 'python'},
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

-- ###############
-- ## Nvim Tree ##
-- ###############
local function nvim_tree_attach(buffer)
  local api = require('nvim-tree.api')
  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end
  api.config.mappings.default_on_attach(buffer)

  vim.keymap.set('n', '%', api.fs.create, opts('Create'))
end

require("nvim-tree").setup({
  on_attach = nvim_tree_attach,
  actions = {
    open_file = {
      quit_on_open = true,
    }
  }
})


-- Magic
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("NvimTreeClose", {clear = true}),
  pattern = "NvimTree_*",
  callback = function()
    local layout = vim.api.nvim_call_function("winlayout", {})
    if layout[1] == "leaf" and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree" and layout[3] == nil then vim.cmd("confirm quit") end
  end
})
-- Magic End

-- ###############
-- ## Mini.Nvim ##
-- ###############
require('mini.move').setup()


-- Telescope
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    generic_sorter = require('telescope.sorters').get_fzy_sorter,
    file_sorter = require('telescope.sorters').get_fzy_sorter,
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}


-- ##############
-- ## Keybinds ##
-- ##############
-- Nvim Tree
vim.keymap.set('n', '<leader>e', function()
  vim.cmd [[NvimTreeToggle]]
end, { desc = 'Toggle [e]xplorer'})

vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[s]earch [f]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[s]earch [h]elp' })
vim.keymap.set('n', '<leader>sb', require('telescope.builtin').oldfiles, { desc = '[sb] Find recently opened files' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').git_files, { desc = '[s]earch [g]it files' })
vim.keymap.set('n', '<leader>sc', function() 
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[s]earch [c]urrent buffer' })

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


vim.o.tabstop=4
vim.o.shiftwidth=4
vim.o.expandtab=true

-- ###########
-- ## Theme ##
-- ###########
vim.cmd [[colorscheme moonfly]]


-- ##########################################
-- ## Secrete Sauce i don't yet understand ##
-- ##########################################
--
-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

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

vim.o.breakindent = true
vim.wo.signcolumn = 'yes'

