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

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { silent = true, desc = 'Go to definition' })
    vim.keymap.set('n', 'gh', show_documentation, { silent = true, desc = 'Go to documentation/help' })

    vim.keymap.set('n', '<Leader>c', vim.lsp.buf.code_action, { silent = true, desc = 'Code action' })
    vim.keymap.set('n', '<Leader>d', vim.lsp.buf.definition, { silent = true, desc = 'Go to definition' })
    vim.keymap.set('n', '<Leader>r', vim.lsp.buf.references, { silent = true, desc = 'Show references' })
    vim.keymap.set('n', '<Leader>i', vim.lsp.buf.implementation, { silent = true, desc = 'Go to implementation' })
    vim.keymap.set('n', '<Leader>e', vim.diagnostic.setqflist, { silent = true, desc = 'Show errors/diagnostics' })
    vim.keymap.set('n', '<leader>E', function()
        vim.cmd('cclose')
        vim.diagnostic.open_float()
    end, { silent = true, desc = 'Close diagnostics and/or open hover' })
end

-- Grow selection with Ctrl-S
if vim.fn.has('nvim-0.12') == 1 then
    local keymap = vim.keymap.set
    keymap('n', '<C-S>', ':normal van<cr>', { silent = true, desc = 'Select / grow selection' })
    keymap('v', '<C-S>', function()
        vim.api.nvim_feedkeys('an', 'v', false)
    end, { silent = true, desc = 'Select / grow selection' })
    keymap('n', '<C-Shift-s>', ':normal vin<cr>', { silent = true, desc = 'Select / grow selection (inner)' })
    keymap('v', '<C-Shift-s>', function()
        vim.api.nvim_feedkeys('in', 'v', false)
    end, { silent = true, desc = 'Select / grow selection (inner)' })
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

local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()

-- blink completion (if coc.nvim not loaded)
local ok, blink = pcall(require, 'blink.cmp')
if ok and not vim.g.did_coc_loaded and vim.fn.executable('cargo') then
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
    end, { desc = 'around method' })
    vim.keymap.set({ "x", "o" }, "im", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
    end, { desc = 'in method' })
    vim.keymap.set({ "x", "o" }, "af", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
    end, { desc = 'around function' })
    vim.keymap.set({ "x", "o" }, "if", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
    end, { desc = 'in function' })

    -- class (ac/ic)
    vim.keymap.set({ "x", "o" }, "ac", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
    end, { desc = 'around class' })
    vim.keymap.set({ "x", "o" }, "ic", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
    end, { desc = 'in class' })

    -- comment (ao/io) - may not work well with multiple single-line comments
    vim.keymap.set({ "x", "o" }, "ao", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@comment.outer", "textobjects")
    end, { desc = 'around comment' })
    vim.keymap.set({ "x", "o" }, "io", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@comment.inner", "textobjects")
    end, { desc = 'in comment' })

    -- local scope (il)
    vim.keymap.set({ "x", "o" }, "il", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@local.scope", "locals")
    end, { desc = 'local scope' })

    -- move - [m / ]m moves between methods
    vim.keymap.set({ "n", "x", "o" }, "]m", function()
        require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
    end, { desc = 'next method/function' })
    vim.keymap.set({ "n", "x", "o" }, "[m", function()
        require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
    end, { desc = 'previous method/function' })
    vim.keymap.set({ "n", "x", "o" }, "]s", function()
        require("nvim-treesitter-textobjects.move").goto_next_start("@local.scope", "locals")
    end, { desc = 'next scope' })
    vim.keymap.set({ "n", "x", "o" }, "[s", function()
        require("nvim-treesitter-textobjects.move").goto_previous_start("@local.scope", "locals")
    end, { desc = 'previous scope' })

    -- swap \w forwards / \W backwards, p parameter, m function
    vim.keymap.set("n", "<leader>wf", function()
        require("nvim-treesitter-textobjects.swap").swap_next "@function.outer"
    end, { desc = 'swap with next function' })
    vim.keymap.set("n", "<leader>Wf", function()
        require("nvim-treesitter-textobjects.swap").swap_previous "@function.outer"
    end, { desc = 'swap with previous function' })
    vim.keymap.set("n", "<leader>wm", function()
        require("nvim-treesitter-textobjects.swap").swap_next "@function.outer"
    end, { desc = 'swap with next method' })
    vim.keymap.set("n", "<leader>Wm", function()
        require("nvim-treesitter-textobjects.swap").swap_previous "@function.outer"
    end, { desc = 'swap with previous method' })
    vim.keymap.set("n", "<leader>wF", function()
        require("nvim-treesitter-textobjects.swap").swap_next "@function.inner"
    end, { desc = 'swap body with next function' })
    vim.keymap.set("n", "<leader>WF", function()
        require("nvim-treesitter-textobjects.swap").swap_previous "@function.inner"
    end, { desc = 'swap body with previous function' })
    vim.keymap.set("n", "<leader>wM", function()
        require("nvim-treesitter-textobjects.swap").swap_next "@function.inner"
    end, { desc = 'swap body with next method' })
    vim.keymap.set("n", "<leader>WM", function()
        require("nvim-treesitter-textobjects.swap").swap_previous "@function.inner"
    end, { desc = 'swap body with previous method' })
    vim.keymap.set("n", "<leader>wp", function()
        require("nvim-treesitter-textobjects.swap").swap_next "@parameter.outer"
    end, { desc = 'swap with next parameter' })
    vim.keymap.set("n", "<leader>Wp", function()
        require("nvim-treesitter-textobjects.swap").swap_previous "@parameter.outer"
    end, { desc = 'swap with previous parameter' })
    vim.keymap.set("n", "<leader>wP", function()
        require("nvim-treesitter-textobjects.swap").swap_next "@parameter.inner"
    end, { desc = 'swap value with next parameter' })
    vim.keymap.set("n", "<leader>WP", function()
        require("nvim-treesitter-textobjects.swap").swap_previous "@parameter.inner"
    end, { desc = 'swap value with previous parameter' })
end

-- aerial \a
local ok, aerial = pcall(require, 'aerial')
if ok then
    aerial.setup({
        on_attach = function(bufnr)
            -- Jump forwards/backwards with '[[' and ']]'
            vim.keymap.set("n", "[[", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = 'next in Aerial outline' })
            vim.keymap.set("n", "]]", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = 'previous in Aerial outline' })
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

    vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>", { desc = 'toggle Aerial outline' })
end

-- auto-session

local ok, autosession = pcall(require, 'auto-session')
if ok then
    local function should_create_session()
        local argc = vim.fn.argc()

        if argc == 0 then
            return true
        end

        if argc == 1 then
            local arg = vim.fn.argv(0)
            if type(arg) ~= "string" then
                return false
            end

            if vim.startswith(arg, "-") then
                return false
            end

            local stat = vim.loop.fs_stat(arg)
            return stat and stat.type == "directory"
        end

        return false
    end

    autosession.setup {
        auto_save = true,
        auto_restore = true,
        auto_create = should_create_session,

        -- On startup, loads the last saved session if session for cwd does not exist
        auto_restore_last_session = false,

        -- Automatically save/restore sessions when changing directories
        cwd_change_handling = false,

        -- Enable single session mode to keep all work in one session
        -- regardless of cwd changes. When enabled, prevents creation of
        -- separate sessions for different directories and maintains one
        -- unified session. Does not work with cwd_change_handling.
        single_session_mode = true,

        -- Suppress session restore/create in certain directories
        suppressed_dirs = nil,

        -- Allow session restore/create in certain directories
        allowed_dirs = nil,

        -- List of filetypes to bypass auto save when the only buffer open is
        -- one of the file types listed, useful to ignore dashboards
        bypass_save_filetypes = { 'gitcommit', 'gitsendemail', 'email', '' },

        -- Include git branch name in session name, can also be a function
        -- that takes an optional path and returns the name of the branch
        git_use_branch_name = false,

        -- Should we auto-restore the session when the git branch changes.
        -- Requires git_use_branch_name
        git_auto_restore_on_branch_change = false,

        -- Function that can return a string to be used as part of the session name
        custom_session_tag = nil,

        -- Enables/disables deleting the session if there are only
        -- unnamed/empty buffers when auto-saving
        auto_delete_empty_sessions = true,

        -- Sessions older than purge_after_minutes will be deleted
        -- asynchronously on startup
        purge_after_minutes = 129600,

        -- Follow normal session save/load logic if launched with a single
        -- directory as the only argument
        args_allow_single_directory = true,

        -- Allow saving a session even when launched with a file argument
        args_allow_files_auto_save = false,

        -- Whether to show a notification when auto-restoring
        show_auto_restore_notif = true,

        -- Define legacy commands: Session*, Autosession (lowercase s)
        legacy_cmds = false,
    }
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

local function executable_exists(cmd)
    return type(cmd) == 'table' and type(cmd[1]) == 'string' and vim.fn.executable(cmd[1]) == 1
end

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
