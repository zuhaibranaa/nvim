local function my_on_attach(bufnr)
	local api = require("nvim-tree.api")

	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	-- default mappings
	api.config.mappings.default_on_attach(bufnr)

	vim.keymap.set("n", "<C-t>", api.tree.change_root_to_parent, opts("Up"))
	vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))

	-- Single click to expand/collapse folders (files unaffected)
	vim.keymap.set("n", "<LeftRelease>", function()
		local node = api.tree.get_node_under_cursor()
		if node and node.type == "directory" then
			api.node.open.edit()
		end
	end, opts("Single click expand/collapse folder"))
end

return {
	"nvim-tree/nvim-tree.lua",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},

	config = function()
		local nvimTree = require("nvim-tree")
		nvimTree.setup({
			on_attach = my_on_attach,
			filters = {
				dotfiles = false,
			},
		})

		-- When a buffer is closed and Neovim falls back to [No Name], redirect to
		-- the most recent real buffer instead. Prevents empty ghost buffers.
		vim.api.nvim_create_autocmd("BufEnter", {
			nested = true, -- allow the subsequent BufEnter (auto-reveal) to fire normally
			callback = function()
				local bufname = vim.api.nvim_buf_get_name(0)

				-- Only act on the unnamed, normal fallback buffer Neovim creates
				if bufname ~= "" or vim.bo.buftype ~= "" or vim.bo.filetype == "NvimTree" then
					return
				end

				-- Collect all valid, listed, named buffers
				local real_bufs = vim.tbl_filter(function(b)
					return vim.api.nvim_buf_is_valid(b)
						and vim.fn.buflisted(b) == 1
						and vim.api.nvim_buf_get_name(b) ~= ""
				end, vim.api.nvim_list_bufs())

				if #real_bufs > 0 then
					-- Jump to the most recently listed real buffer and wipe the empty one
					local empty_buf = vim.api.nvim_get_current_buf()
					vim.api.nvim_set_current_buf(real_bufs[#real_bufs])
					pcall(vim.api.nvim_buf_delete, empty_buf, { force = true })
				end
			end,
		})

		-- Auto-reveal current file in tree when switching buffers (like VSCode)
		-- Only runs when the tree is already open; does not steal focus
		vim.api.nvim_create_autocmd("BufEnter", {
			callback = function()
				local bufname = vim.api.nvim_buf_get_name(0)

				-- Skip: nvim-tree buffer, unnamed buffers, non-file buffers (terminal, quickfix, etc.)
				if bufname == "" or vim.bo.filetype == "NvimTree" or vim.bo.buftype ~= "" then
					return
				end

				local view = require("nvim-tree.view")
				if view.is_visible() then
					require("nvim-tree.api").tree.find_file({
						buf = vim.api.nvim_get_current_buf(),
						open = false,  -- don't open tree if closed
						focus = false, -- don't steal focus from the file
					})
				end
			end,
		})
	end,
}
