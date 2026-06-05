return {
	"stevearc/oil.nvim",
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {},
	-- Optional dependencies
	-- dependencies = { { "nvim-mini/mini.icons", opts = {} } },
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
	-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
	lazy = false,

	config = function()
		local oil = require("oil")
		oil.setup({
			columns = {
				"icon",
			},
			default_file_explorer = true,
			win_options = {
				signcolumn = "yes",
			},
			view_options = {
				show_hidden = true,
				is_hidden_file = function(name, bufnr)
					local m = name:match("^%.")
					return m ~= nil
				end,
			},
		})

		vim.keymap.set("n", "<leader>t", "<CMD>Oil<CR>", { desc = "Open parent directory" })
		vim.keymap.set("n", "<leader>-", oil.toggle_float, { desc = "Toggle parent directory in a floating window" })
	end,
}
