return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		-- Install parsers (no-op if already installed)
		require("nvim-treesitter").install({
			"vimdoc",
			"markdown",
			"lua",
			"javascript",
			"scss",
			"typescript",
			"tsx",
			"html",
			"css",
			"python",
		})

		-- Enable treesitter highlighting for all filetypes
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				pcall(vim.treesitter.start)
			end,
		})
	end,
}
