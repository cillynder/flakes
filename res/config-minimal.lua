-- Keybindings
local map = vim.keymap.set
map('n', '<C-H>', '<C-W>h', { noremap = true })
map('n', '<C-J>', '<C-W>j', { noremap = true })
map('n', '<C-K>', '<C-W>k', { noremap = true })
map('n', '<C-L>', '<C-W>l', { noremap = true })
map('n', '<C-Q>', ':q<CR>', { noremap = true })
map('n', '<C-P>', ':Files<CR>', { noremap = true })

-- Autocommands
vim.cmd('au BufEnter * set noro')
vim.cmd('au CursorHold * lua vim.diagnostic.open_float(0, { scope = "line", focusable = false })')

-- Settings
vim.opt.mouse = ""
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes:3"
vim.opt.title = true
vim.opt.termguicolors = true
vim.opt.updatetime = 0
vim.opt.clipboard:prepend('unnamedplus')

local runtimedir = os.getenv('XDG_RUNTIME_DIR')
vim.opt.directory:prepend(runtimedir..'/vim/swap//')
vim.opt.undodir:prepend(runtimedir..'/vim/undo//')
vim.opt.swapfile = true
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true

vim.opt.tabstop = 8
vim.opt.softtabstop = 0
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.smarttab = true

vim.g.signify_priority               = 5
vim.g.signify_sign_show_count        = 0
vim.g.signify_sign_add               = '┃'
vim.g.signify_sign_delete            = vim.g.signify_sign_add
vim.g.signify_sign_delete_first_line = '┏━'
vim.g.signify_sign_change            = vim.g.signify_sign_add
vim.g.signify_sign_change_delete     = vim.g.signify_sign_delete

-- Plugins
require('nvim-treesitter').setup {
    highlight = { enable = true },
    indent = { enable = false }
}
require('lualine').setup { }
