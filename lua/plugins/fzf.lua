return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	---@module "fzf-lua"
	---@type fzf-lua.Config|{}
	---@diagnostic disable: missing-fields
	opts = {},
	---@diagnostic enable: missing-fields
	keys = {
		{
			"<leader>ff",
			function()
				require("fzf-lua").files()
			end,
			desc = "FZF find files",
		},
		{
			"<leader>fg",
			function()
				require("fzf-lua").live_grep()
			end,
			desc = "FZF live grep",
		},
		{
			"<leader>fb",
			function()
				require("fzf-lua").buffers()
			end,
			desc = "FZF buffers",
		},
		{
			"<leader>fh",
			function()
				require("fzf-lua").help_tags()
			end,
			desc = "FZF help tags",
		},
		{
			"<leader>gc",
			function()
				require("fzf-lua").git_status()
			end,
			desc = "FZF git changed files",
		},
	},
	config = function()
		local fzf = require("fzf-lua")

		fzf.setup({
			winopts = {
				height = 0.85,
				width = 0.80,
				row = 0.35,
				col = 0.50,
				border = "rounded",
			},
			defaults = {
				file_ignore_patterns = { "node_modules", "dist" },
			},
			keymap = {
				builtin = {
					["<C-q>"] = "select-all+accept",
				},
			},
			fzf_colors = {
				["hl"] = { "fg", "Search" },
				["hl+"] = { "fg", "Search", "bold", "reverse" },
			},
		})
	end,
}
