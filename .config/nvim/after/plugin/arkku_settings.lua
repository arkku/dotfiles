-- Persistent undo (off by default, use `:earlier 0f` to return to last save)
if vim.env.VIMUNDO == "1" then
    local undodir = vim.fn.expand("~/.local/state/nvim/undo")
    if vim.fn.isdirectory(undodir) == 0 then
        vim.fn.mkdir(undodir, "p")
    end
    vim.opt.undodir = undodir
    vim.opt.undofile = true
    vim.opt.undolevels = 4096
end

-- Restore cursor on load, except for some filetypes
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function(event)
        local exclude = {
            gitcommit = true,
            gitrebase = true,
            diff = true,
            wdiff = true,
            gitsendemail = true,
            mail = true,
        }

        local ft = vim.bo[event.buf].filetype
        if exclude[ft] then
            return
        end

        local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
        local lcount = vim.api.nvim_buf_line_count(event.buf)

        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- coc.nvim compatibility bindings without coc.nvim
if not vim.g.did_coc_loaded then
    local function show_documentation()
        if vim.bo.filetype == 'vim' then
            vim.cmd('h ' .. vim.fn.expand('<cword>'))
        else
            vim.lsp.buf.hover()
        end
    end

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { silent = true })
    vim.keymap.set('n', 'gh', show_documentation, { silent = true })

    vim.keymap.set('n', '<Leader>c', vim.lsp.buf.code_action, { silent = true })
    vim.keymap.set('n', '<Leader>d', vim.lsp.buf.definition, { silent = true })
    vim.keymap.set('n', '<Leader>r', vim.lsp.buf.references, { silent = true })
    vim.keymap.set('n', '<Leader>i', vim.lsp.buf.implementation, { silent = true })
    vim.keymap.set('n', '<Leader>R', vim.lsp.buf.rename, { silent = true })
    vim.keymap.set('n', '<Leader>e', vim.diagnostic.setloclist, { silent = true })
end

-- Grow selection with Ctrl-S
if vim.fn.has('nvim-0.12') == 1 then
    local keymap = vim.keymap.set
    keymap('n', '<C-S>', ':normal van<cr>', opts)
    keymap('v', '<C-S>', function()
        vim.api.nvim_feedkeys('an', 'v', false)
    end)
    keymap('n', '<C-Shift-s>', ':normal vin<cr>', opts)
    keymap('v', '<C-Shift-s>', function()
        vim.api.nvim_feedkeys('in', 'v', false)
    end)
end

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'typescript', 'json' },
    callback = function()
        vim.bo.formatexpr = 'v:lua.vim.lsp.formatexpr()'
    end
})

--- LSP support

local has_native_lsp = type(vim.lsp.enable) == 'function' and vim.lsp.config ~= nil
local lspconfig = nil

local has_lazydev = false

if has_native_lsp then
    local ok, lazydev = pcall(require, 'lazydev')
    if ok then
        lazydev.setup {
            library = { 'nvim-dap-ui' },
        }
        has_lazydev = true
    end
else
    local ok, lspconfig_mod = pcall(require, 'lspconfig')
    if ok then
        lspconfig = lspconfig_mod
    end
end

local function executable_exists(cmd)
    return type(cmd) == 'table' and type(cmd[1]) == 'string' and vim.fn.executable(cmd[1]) == 1
end

local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()

-- blink completion (if coc.nvim not loaded)
local ok, blink = pcall(require, 'blink.cmp')
if ok and not vim.g.did_coc_loaded then
    if vim.g.loaded_supertab then
        -- Remove supertab mappings (they don't work with blink)
        vim.keymap.set('i', '<Tab>', '<Tab>',  { noremap = true, silent = true })
        vim.keymap.set('i', '<C-n>', '<C-n>', { noremap = true, silent = true })
        vim.keymap.set('i', '<C-p>', '<C-p>', { noremap = true, silent = true })
    else
        -- Prevent supertab from loading
        vim.g.loaded_supertab = 1
    end

    local keymap = {
        -- 'default' for mappings similar to built-in completions (C-y to accept)
        -- 'super-tab' for mappings similar to vscode (tab to accept)
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        preset = 'super-tab',

        ['<Tab>'] = {
            function(cmp)
                if cmp.snippet_active() then return cmp.accept()
                else return cmp.select_and_accept() end
            end,
            'snippet_forward',
            'fallback'
        },
        ['<C-n>'] = { 'show', 'select_next', 'fallback' },
        ['<C-p>'] = { 'show', 'select_prev', 'fallback' },
        ['<C-y>'] = { 'select_and_accept', 'fallback' },
    }

    local providers = {}
    local default_providers = { 'lsp', 'path', 'snippets', 'buffer' }

    -- If minuet-ai is installed, add it as a provider and bind to <C-k>
    -- (do not include by default since it's slow and costs tokens)
    local ok, minuet = pcall(require, 'minuet')
    if ok then
        providers['minuet'] = {
            name = 'minuet',
            module = 'minuet.blink',
            async = true,
            -- Should match minuet.config.request_timeout * 1000,
            -- since minuet.config.request_timeout is in seconds
            timeout_ms = 3000,
            score_offset = 100,
        }
        keymap["<C-k>"] = minuet.make_blink_map()
    end

    if has_lazydev then
        providers['lazydev'] = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 50,
        }
        table.insert(default_providers, 2, 'lazydev')
    end

    providers['default'] = default_providers

    local disable_auto_show_in = {
        diff = true,
        gitcommit = true,
        gitrebase = true,
        gitsendemail = true,
        latex = true,
        mail = true,
        markdown = true,
        text = true,
        textile = true,
        wdiff = true,
        [""] = true,
    }

    blink.build():wait(60000)
    blink.setup {
        keymap = keymap,

        sources = {
            providers = providers,
        },

        fuzzy = {
            implementation = "prefer_rust",
        },

        cmdline = {
            enabled = false,
        },

        signature = {
            enabled = true,
        },

        completion = {
            -- 'prefix' will fuzzy match on the text before the cursor
            -- 'full' will fuzzy match on the text before _and_ after the cursor
            -- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
            keyword = { range = 'prefix' },

            accept = {
                auto_brackets = {
                    enabled = true,
                },
            },

            ghost_text = {
                enabled = function()
                    local ft = vim.bo.filetype
                    return not disable_auto_show_in[ft]
                end,
                show_with_menu = false,
            },

            menu = {
                auto_show = function()
                    local ft = vim.bo.filetype
                    return not disable_auto_show_in[ft]
                end,
            },

            documentation = {
                auto_show = true,
            },

            list = {
                selection = {
                    auto_insert = false,

                    preselect = function(ctx)
                        return not require('blink.cmp').snippet_active({ direction = 1 })
                    end
                }
            },
        },
    }

    lsp_capabilities = blink.get_lsp_capabilities(lsp_capabilities)
elseif vim.fn.exists('+autocomplete') == 1 then
    -- nvim 0.12 native autocomplete if blink is not installed
    vim.o.autocomplete = true
end

-- nvim-treesitter-textobjects
local ok, tstexto = pcall(require, 'nvim-treesitter-textobjects')
if ok then
    tstexto.setup {
        move = {
            -- whether to set jumps in the jumplist
            set_jumps = true,
        },
        select = {
            include_surrounding_whitespace = true,
        }
    }

    -- method / function (map both af/am if/im)
    vim.keymap.set({ "x", "o" }, "am", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "im", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "af", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "if", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
    end)

    -- class (ac/ic)
    vim.keymap.set({ "x", "o" }, "ac", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "ic", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
    end)

    -- comment (ao/io) - may not work well with multiple single-line comments
    vim.keymap.set({ "x", "o" }, "ao", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@comment.outer", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "io", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@comment.inner", "textobjects")
    end)

    -- local scope (il)
    vim.keymap.set({ "x", "o" }, "il", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@local.scope", "locals")
    end)

    -- move - [m / ]m moves between methods
    vim.keymap.set({ "n", "x", "o" }, "]m", function()
        require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "n", "x", "o" }, "[m", function()
        require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "n", "x", "o" }, "]s", function()
        require("nvim-treesitter-textobjects.move").goto_next_start("@local.scope", "locals")
    end)
    vim.keymap.set({ "n", "x", "o" }, "[s", function()
        require("nvim-treesitter-textobjects.move").goto_previous_start("@local.scope", "locals")
    end)

    -- swap \w forwards / \W backwards, p parameter, m function
    vim.keymap.set("n", "<leader>wf", function()
        require("nvim-treesitter-textobjects.swap").swap_next "@function.outer"
    end)
    vim.keymap.set("n", "<leader>Wf", function()
        require("nvim-treesitter-textobjects.swap").swap_previous "@function.outer"
    end)
    vim.keymap.set("n", "<leader>wm", function()
        require("nvim-treesitter-textobjects.swap").swap_next "@function.outer"
    end)
    vim.keymap.set("n", "<leader>Wm", function()
        require("nvim-treesitter-textobjects.swap").swap_previous "@function.outer"
    end)
    vim.keymap.set("n", "<leader>wF", function()
        require("nvim-treesitter-textobjects.swap").swap_next "@function.inner"
    end)
    vim.keymap.set("n", "<leader>WF", function()
        require("nvim-treesitter-textobjects.swap").swap_previous "@function.inner"
    end)
    vim.keymap.set("n", "<leader>wM", function()
        require("nvim-treesitter-textobjects.swap").swap_next "@function.inner"
    end)
    vim.keymap.set("n", "<leader>WM", function()
        require("nvim-treesitter-textobjects.swap").swap_previous "@function.inner"
    end)
    vim.keymap.set("n", "<leader>wp", function()
        require("nvim-treesitter-textobjects.swap").swap_next "@parameter.outer"
    end)
    vim.keymap.set("n", "<leader>Wp", function()
        require("nvim-treesitter-textobjects.swap").swap_previous "@parameter.outer"
    end)
    vim.keymap.set("n", "<leader>wP", function()
        require("nvim-treesitter-textobjects.swap").swap_next "@parameter.inner"
    end)
    vim.keymap.set("n", "<leader>WP", function()
        require("nvim-treesitter-textobjects.swap").swap_previous "@parameter.inner"
    end)
end

-- aerial \a
local ok, aerial = pcall(require, 'aerial')
if ok then
    require("aerial").setup({
        on_attach = function(bufnr)
            -- Jump forwards/backwards with '[[' and ']]'
            vim.keymap.set("n", "[[", "<cmd>AerialPrev<CR>", { buffer = bufnr })
            vim.keymap.set("n", "]]", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end,

        highlight_mode = "split_width",
        highlight_closest = true,
        highlight_on_hover = true,

        -- Automatically jump to the symbol in source when moving cursor
        -- in the Aerial window
        autojump = true,

        ignore = {
            unlisted_buffers = false,

            filetypes = {
                'fzf',
            },

            buftypes = "special",
            wintypes = "special",
        },

        -- Use symbol tree for folding. Set to true or false to enable/disable
        -- Set to "auto" to manage folds if your previous foldmethod was 'manual'
        -- This can be a filetype map (see :help aerial-filetype-map)
        manage_folds = "auto",

        nerd_font = "auto",

        show_guides = true,
    })

    vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
end

-- LSPs

local ok, tsmgr = pcall(require, 'tree-sitter-manager')
if ok then
    tsmgr.setup({
        languages = {
            crystal = {
                install_info = {
                    url = "https://github.com/crystal-lang-tools/tree-sitter-crystal",
                    use_repo_queries = true,
                },
            },
        },
    })
end

local servers = {
    autotools_ls    = {},
    basedpyright    = {},
    bashls          = { filetypes = { 'sh', 'bash', 'zsh', }, },
    clangd          = {},
    crystalline     = {},
    cssls           = {},
    dartls          = {},
    elixirls        = {},
    eslint          = {},
    gopls           = {},
    hls             = {},
    html            = {},
    jsonls          = {},
    kotlin_lsp      = { cmd = { 'kotlin-lsp', '--stdio' }, },
    lua_ls          = {},
    marksman        = {},
    metals          = {},
    rust_analyzer   = {},
    solargraph      = {},
    sourcekit       = {},
    ts_ls           = {},
    vimls           = {},
    zls             = {},
}

for name, cfg in pairs(servers) do
    if not cfg.cmd or executable_exists(cfg.cmd) then
        local server_cfg = vim.deepcopy(cfg)
        server_cfg.capabilities = lsp_capabilities
        if has_native_lsp then
            local template = vim.lsp.config[name]
            if template or cfg.cmd then
                vim.lsp.config(name, server_cfg)
                vim.lsp.enable(name)
            end
        elseif lspconfig then
            local template = lspconfig[name]
            if template then
                lspconfig[name].setup(server_cfg)
            end
        end
    end
end
