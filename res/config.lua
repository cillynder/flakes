-- Keybindings
local map = vim.keymap.set
map('n', '<C-H>', '<C-W>h', { remap = false })
map('n', '<C-J>', '<C-W>j', { remap = false })
map('n', '<C-K>', '<C-W>k', { remap = false })
map('n', '<C-L>', '<C-W>l', { remap = false })
map('n', '<C-Q>', ':q<CR>', { remap = false })
map('n', '<C-P>', ':Files<CR>', { remap = false })
map('n', '<C-/>', 'gcc', { remap = true, silent = true })
map('v', '<C-/>', 'gc', { remap = true, silent = true })

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

-- VimTeX
vim.g.vimtex_view_method = "zathura"

-- Theming
vim.api.nvim_command("syntax enable")
local colors = require("catppuccin.palettes").get_palette "{{CATPPUCCIN_FLAVOUR}}"
vim.cmd("highlight SignifySignAdd             guifg="..colors.green)
vim.cmd("highlight SignifySignChange          guifg="..colors.peach)
vim.cmd("highlight SignifySignDelete          guifg="..colors.red)
vim.cmd("highlight SignifySignDeleteFirstLine guifg="..colors.red)
vim.cmd("highlight SignifySignChangeDelete    guifg="..colors.red)

-- Set this specific highlight group in rust
-- Shown when using #[cfg] directives, entire chunks of disabled code has squiggly lines and I don't want
-- to see it
vim.cmd("au FileType rust highlight DiagnosticUnderlineHint ctermfg=14 gui=italic guifg="..colors.overlay2)

-- Plugins
require('autoclose').setup {}
local function autosavecond(buf)
    if vim.tbl_contains({"astro", "tex"}, vim.fn.getbufvar(buf, "&filetype")) then
        return true
    end
    return false
end
require('auto-save').setup {
    trigger_events = {
        defer_save = { "InsertLeave", "TextChanged", "TextChangedI" },
    },
    debounce_delay = 250,
    condition = autosavecond,
}
require('nvim-ts-autotag').setup {}
require('nvim-highlight-colors').setup {
    render = "virtual",
}
require('nvim-treesitter').setup {
    highlight = { enable = true },
    indent = { enable = false }
}
require('lualine').setup {
    options = {
        theme = 'catppuccin'
    },
    sections = {
        lualine_c = {
            {
                "filename",
                path = 1,
            }
        }
    }
}

-- Block comments indent workaround
-- many thanks to @kristijanhusak
-- https://github.com/nvim-treesitter/nvim-treesitter/issues/1167#issuecomment-920824125
function _G.javascript_indent()
  local line = vim.fn.getline(vim.v.lnum)
  local prev_line = vim.fn.getline(vim.v.lnum - 1)
  if line:match('^%s*[%*/]%s*') then
    if prev_line:match('^%s*%*%s*') then
      return vim.fn.indent(vim.v.lnum - 1)
    end
    if prev_line:match('^%s*/%*%*%s*$') then
      return vim.fn.indent(vim.v.lnum - 1) + 1
    end
  end

  return vim.fn['GetJavascriptIndent']()
end

vim.cmd('au FileType javascript setlocal indentexpr=v:lua.javascript_indent()')

-- LSP
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
            return
        end

        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(args.buf, ...) end
        local function buf_set_option(...) vim.api.nvim_buf_set_option(args.buf, ...) end

        local opts = { noremap = true, silent = true }

        buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
        buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float(0, { scope = "line" })<CR>', opts)
        buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
        buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
        buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
    end
})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        focusable = false,
        virtual_text = false,
        underline = true,
        signs = true,
        update_in_insert = true
    }
)
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, { focusable = false }
)

capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local servers = { 'astro', 'clangd', 'cssls', 'html', 'nil_ls', 'tailwindcss', 'texlab', 'ts_ls', 'yamlls' }
for _, lsp in ipairs(servers) do
    vim.lsp.config(lsp, {
        capabilities = capabilities,
        flags = { debounce_text_changes = 150 }
    })
    vim.lsp.enable(lsp)
end

-- nvim-cmp
local luasnip = require('luasnip')
local cmp = require('cmp')
cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end
    },
    mapping = {
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-N>'] = cmp.mapping.select_prev_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Tab>'] = function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
            else
                fallback()
            end
        end,
        ['<S-Tab>'] = function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '')
            else
                fallback()
            end
        end
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' }
    }
}

-- LSP/Omnisharp
local pid = vim.fn.getpid()
vim.lsp.config("omnisharp", {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = { debounce_text_changes = 150 },
    cmd = { "{{OMNISHARP_PATH}}", "--languageserver", "--hostPID", tostring(pid) }
})
vim.lsp.enable("omnisharp")

-- LSP/rust_analyzer
vim.lsp.config("rust_analyzer", {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = { debounce_text_changes = 150 },
    settings = {
        ["rust-analyzer"] = {
            imports = {
                granularity = {
                    enforce = true,
                    group = "module"
                }
            },
            diagnostics = {
                disabled = { "incorrect-ident-case" }
            }
        }
    }
})
vim.lsp.enable("rust_analyzer")

-- LSP/Diagnostics
vim.lsp.config("diagnosticls", {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = { debounce_text_changes = 150 },
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
    init_options = {
        linters = {
            eslint = {
                command = 'eslint_d',
                rootPatterns = { '.git' },
                debounce = 100,
                args = { '--stdin', '--stdin-filename', '%filepath', '--format', 'json' },
                sourceName = 'eslint',
                parseJson = {
                    errorsRoot = '[0].messages',
                    line = 'line',
                    column = 'column',
                    endLine = 'endLine',
                    endColumn = 'endColumn',
                    message = '[eslint] ${message} [${ruleId}]',
                    security = 'severity'
                },
                securities = {
                    [2] = 'error',
                    [1] = 'warning'
                }
            }
        },
        filetypes = {
            javascript = 'eslint',
            javascriptreact = 'eslint',
            typescript = 'eslint',
            typescriptreact = 'eslint',
            vue = 'eslint'
        }
    }
})
vim.lsp.enable("diagnosticls")

-- LSP/Signatures
require("lsp_signature").setup {
    hint_enable = false,
    handler_opts = { border = "none" },
    fix_pos = true
}

-- LSP/fzf
require("fzf_lsp").setup()

-- LSP/flutter
require("flutter-tools").setup {
    debugger = {
        enabled = true
    },
    lsp = {
        on_attach = on_attach,
        cmd = { "{{DART_PATH}}", "language-server", "--protocol=lsp" }
    }
}
