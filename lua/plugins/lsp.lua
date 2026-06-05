return { -- Main LSP Configuration
    "neovim/nvim-lspconfig",
    dependencies = {
        -- Automatically install LSPs and related tools to stdpath for Neovim
        { "mason-org/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
        "mason-org/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",

        -- Useful status updates for LSP.
        -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
        { "j-hui/fidget.nvim",    opts = {} },

        -- Replaced cmp-nvim-lsp with blink.cmp
        "saghen/blink.cmp",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        -- Brief aside: **What is LSP?**
        --
        -- LSP is an initialism you've probably heard, but might not understand what it is.
        --      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
        -- and language tooling communicate in a standardized fashion.
        --
        -- In general, you have a "server" which is some tool built to understand a particular
        -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
        -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
        -- processes that communicate with some "client" - in this case, Neovim!
        --
        -- LSP provides Neovim with features like:
        --  - Go to definition
        --  - Find references
        --  - Autocompletion
        --  - Symbol Search
        --  - and more!
        --
        -- Thus, Language Servers are external tools that must be installed separately from
        -- Neovim. This is where `mason` and related plugins come into play.
        --
        -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
        -- and elegantly composed help section, `:help lsp-vs-treesitter`

        --  This function gets run when an LSP attaches to a particular buffer.
        --    That is to say, every time a new file is opened that is associated with
        --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
        --    function will be executed to configure the current buffer
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
            callback = function(event)
                -- NOTE: Remember that Lua is a real programming language, and as such it is possible
                -- to define small helper and utility functions so you don't have to repeat yourself.
                --
                -- In this case, we create a function that lets us more easily define mappings specific
                -- for LSP related items. It sets the mode, buffer and description for us each time.
                local map = function(keys, func, desc, mode)
                    mode = mode or "n"
                    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                end

                local fzf = require("fzf-lua")
                -- Jump to the definition of the word under your cursor.
                --  This is where a variable was first declared, or where a function is defined, etc.
                --  To jump back, press <C-t>.
                -- map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
                map("gd", function()
                    vim.lsp.buf.definition({
                        on_list = function(options)
                            if #options.items == 0 then
                                vim.notify("No definition found", vim.log.levels.WARN)
                                return
                            end
                            if #options.items == 1 then
                                vim.fn.setqflist({}, " ", options)
                                vim.api.nvim_command("cfirst")
                            else
                                local entries = {}
                                for _, item in ipairs(options.items) do
                                    table.insert(
                                        entries,
                                        string.format("%s:%d:%d: %s", item.filename, item.lnum, item.col, item.text)
                                    )
                                end
                                fzf.fzf_exec(entries, {
                                    prompt = "Definitions> ",
                                    previewer = "builtin", -- use fzf-lua's built-in previewer
                                    actions = fzf.defaults.actions.files,
                                })
                            end
                        end,
                    })
                end, "[G]oto [D]efinition")

                map("gr", fzf.lsp_references, "[G]oto [R]eferences")

                -- Jump to the implementation of the word under your cursor.
                --  Useful when your language has ways of declaring types without an actual implementation.
                map("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")

                -- Jump to the type of the word under your cursor.
                --  Useful when you're not sure what type a variable is and you want to see
                --  the definition of its *type*, not where it was *defined*.
                map("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")

                -- Fuzzy find all the symbols in your current document.
                --  Symbols are things like variables, functions, types, etc.
                map("<leader>ds", function()
                    fzf.lsp_document_symbols()
                end, "[D]ocument [S]ymbols")

                -- Fuzzy find all the symbols in your current workspace.
                --  Similar to document symbols, except searches over your entire project.
                map("<leader>ws", vim.lsp.buf.workspace_symbol, "[W]orkspace [S]ymbols")

                -- Rename the variable under your cursor.
                --  Most Language Servers support renaming across files, etc.
                map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

                -- Execute a code action, usually your cursor needs to be on top of an error
                -- or a suggestion from your LSP for this to activate.
                map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

                -- WARN: This is not Goto Definition, this is Goto Declaration.
                --  For example, in C this would take you to the header.
                map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

                -- Show the diagnostics of the current line
                map("<leader>sd", vim.diagnostic.open_float, "[S]show [D]iagnostics of the current line")

                -- Show the diagnostics for the current line
                map("<leader>sD", fzf.diagnostics_document, "[S]how [D]iagnostics")

                -- Move between the diagnostics list in the current document
                map("]d", function()
                    vim.diagnostic.jump({ count = 1 })
                end, "Next [D]iagnostic")
                map("[d", function()
                    vim.diagnostic.jump({ count = -1 })
                end, "Prev [D]iagnostic")

                -- The following two autocommands are used to highlight references of the
                -- word under your cursor when your cursor rests there for a little while.
                --    See `:help CursorHold` for information about when this is executed
                --
                -- When you move your cursor, the highlights will be cleared (the second autocommand).
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                    local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.clear_references,
                    })

                    vim.api.nvim_create_autocmd("LspDetach", {
                        group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
                        callback = function(event2)
                            vim.lsp.buf.clear_references()
                            vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
                        end,
                    })
                end

                -- The following code creates a keymap to toggle inlay hints in your
                -- code, if the language server you are using supports them
                --
                -- This may be unwanted, since they displace some of your code
                if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                    map("<leader>th", function()
                        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
                    end, "[T]oggle Inlay [H]ints")
                end
            end,
        })

        -- LSP servers and clients are able to communicate to each other what features they support.
        --  By default, Neovim doesn't support everything that is in the LSP specification.
        --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
        --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities())

        -- Enable the following language servers
        --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
        --
        --  Add any additional override configuration in the following tables. Available keys are:
        --  - cmd (table): Override the default command used to start the server
        --  - filetypes (table): Override the default list of associated filetypes for the server
        --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
        --  - settings (table): Override the default settings passed when initializing the server.
        --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
        local servers = {
            clangd = {
                on_attach = function(client, bufnr)
                    -- Enable formatting capabilities
                    client.server_capabilities.documentFormattingProvider = true
                    -- Map <Leader>f to formatting command
                    vim.api.nvim_buf_set_keymap(
                        bufnr,
                        "n",
                        "<Leader>f",
                        "<cmd>lua vim.lsp.buf.format{ async = true }<CR>",
                        { noremap = true, silent = true }
                    )

                    vim.api.nvim_create_autocmd("BufWritePre", {
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format({ bufnr = bufnr, async = true })
                        end,
                    })
                end,
            },
            pyright = {},
            rust_analyzer = {},
            -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
            --
            -- Some languages (like typescript) have entire language plugins that can be useful:
            --    https://github.com/pmizio/typescript-tools.nvim
            --
            -- But for many setups, the LSP (`ts_ls`) will work just fine
            ts_ls = {},

            angularls = {
                -- root_dir = function(fname)
                --     local util = require("lspconfig.util")
                --     return util.root_pattern("angular.json", "nx.json")(fname)
                -- end,
                -- filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx", "htmlangular" },
            },

            html = {
                filetypes = { "html", "htmlangular" },
                init_options = {
                    configurationSection = { "html", "css", "javascript" },
                    embeddedLanguages = {
                        css = true,
                        javascript = true,
                    },
                    provideFormatter = true,
                },
            },

            cssls = {
                filetypes = { "css", "scss" },
                settings = {
                    css = { validate = true },
                    less = { validate = true },
                    scss = { validate = true },
                },
            },

            emmet_language_server = {
                filetypes = { "html", "css", "scss", "htmlangular" },
            },

            lua_ls = {
                -- cmd = {...},
                -- filetypes = { ...},
                -- capabilities = {},
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = "Replace",
                        },
                        -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                        -- diagnostics = { disable = { 'missing-fields' } },
                        diagnostics = {
                            globals = { "vim" },
                        },
                    },
                },
            },
            tailwindcss = {
                settings = {
                    tailwindCSS = {
                        includeLanguages = {
                            typescriptreact = "html",
                            javascriptreact = "html",
                        },
                    },
                },
            },
        }

        -- Ensure the servers and tools above are installed
        --  To check the current status of installed tools and/or manually install
        --  other tools, you can run
        --    :Mason
        --
        --  You can press `g?` for help in this menu.
        require("mason").setup()

        -- You can add other tools here that you want Mason to install
        -- for you, so that they are available from within Neovim.
        local ensure_installed = vim.tbl_keys(servers or {})
        vim.list_extend(ensure_installed, {
            "stylua",
            "phpactor",
        })
        require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
        require("mason-lspconfig").setup({
            handlers = {
                function(server_name)
                    local server = servers[server_name] or {}
                    server.capabilities = capabilities
                    require("lspconfig")[server_name].setup(server)
                end,
            },
        })

        -- phpactor: bypass mise shim by using the direct PHP binary.
        -- The mise shim triggers a php@8.4.20 install on every startup, blocking LSP init.
        vim.lsp.config("phpactor", {

            filetypes = { "php" },
            root_markers = { "composer.json", ".phpactor.json", ".phpactor.yml", ".git" },
            workspace_required = false,
            capabilities = capabilities,
        })
        vim.lsp.enable("phpactor")
    end,
}
