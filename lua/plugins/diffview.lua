return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
	keys = {
		{
			"<leader>dv",
			function()
				require("diffview").open()
			end,
			desc = "Diff view open",
		},
		{
			"<leader>dh",
			function()
				require("diffview").file_history(nil, stri)
			end,
			desc = "Repo history",
		},
		{
			"<leader>dH",
			function()
				require("diffview").file_history(nil, "%")
			end,
			desc = "File history",
		},
		{
			"<leader>dx",
			function()
				require("diffview").close()
			end,
			desc = "Diff view close",
		},
	},
	opts = {},
}
