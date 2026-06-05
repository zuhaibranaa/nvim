return {
	"gbprod/nord.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("nord").setup({
			transparent = true,
		})
		vim.cmd.colorscheme("nord")

        -- Force the floating windows to have no background
        vim.api.nvim_create_autocmd("VimEnter", {
            callback = function()
                vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE' })
                vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'NONE' })
            end,
        })

        -- Force the diagnositcs virtual texts to be have no background
        vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextError', { link = 'DiagnosticError' })
        vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextWarn',  { link = 'DiagnosticWarn' })
        vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextInfo',  { link = 'DiagnosticInfo' })
        vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextHint',  { link = 'DiagnosticHint' })
	end,
}
