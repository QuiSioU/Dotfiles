-- options.lua

local opt = vim.opt

-- Line numbers
opt.number         = true
opt.relativenumber = true
opt.numberwidth    = 5

-- Tabs / indentation
opt.expandtab   = false
opt.tabstop     = 4
opt.softtabstop = 0
opt.shiftwidth  = 4
opt.autoindent  = true
opt.smarttab    = true

-- Indentation markers
opt.list      = true
opt.listchars = { tab = "¦ " }

-- Folding
opt.foldmethod = "indent"
opt.foldlevel  = 20

-- Encoding & file format
opt.encoding   = "utf-8"
opt.fileformat = "unix"

-- Wrapping
opt.textwidth = 90
opt.wrap      = true

-- Appearance
opt.termguicolors = true
opt.cursorline    = true
opt.laststatus    = 2
opt.showmode      = false   -- lualine handles this

-- No swap files
opt.swapfile = false

-- Cursor line highlights (same colors as your vimrc)
vim.api.nvim_set_hl(0, "CursorLine",   { bg = "#3A3F58", cterm = {} })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#FFD700", cterm = {} })
vim.api.nvim_set_hl(0, "LineNr",       { fg = "#33384A", cterm = {} })
