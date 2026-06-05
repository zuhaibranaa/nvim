return {
	"norcalli/nvim-colorizer.lua",
	event = "BufReadPost",
	opts = {
		filetypes = { "css", "scss", "html", "javascript", "typescript" },
		user_default_options = {
			css = true,
			tailwind = true,
			mode = "foreground",
		},
	},
}
