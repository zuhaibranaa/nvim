return {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    -- or                              , branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
     config = function()
        -- Setup Telescope

        local function send_only_selected_to_qflist(prompt_bufnr)
            require('telescope.actions').smart_add_to_qflist(prompt_bufnr)
            vim.cmd("copen")
        end

        require('telescope').setup{
            defaults = {
                file_ignore_patterns = { "node_modules", "dist" },
                mappings = {
                    i = {
                        ["<C-q>"] = send_only_selected_to_qflist
                    },
                    n = {
                        ["<C-q>"] = send_only_selected_to_qflist
                    }
                }
            }
        }

        -- Define keymaps for Telescope
        local builtin = require('telescope.builtin')

        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
    end
}
