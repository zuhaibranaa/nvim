return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
		cmdline = {
			enabled = true,
			view = "cmdline_popup",
		},
		messages = {
			enabled = false,
		},
		notify = {
			enabled = false,
		},
		presets = {
			command_palette = false,
			bottom_search = false,
			long_message_to_split = false,
		},
		views = {
			cmdline_popup = {
				position = {
					row = 5,
					col = "50%",
				},
			},
		},
		mini = {
			win_options = {
				winblend = 100,
			},
		},
	},
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		-- OPTIOnAL:
		--   `nvim-notify` is only needed, if you want to use the notification view.
		--   If not available, we use `mini` as the fallback
		"rcarriga/nvim-notify",
	},
}
