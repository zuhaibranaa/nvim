vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- keymaps for nvim-tree
vim.keymap.set("n", "<leader>pv", "<cmd>NvimTreeToggle<CR>")
vim.keymap.set("n", "<leader>pf", "<cmd>NvimTreeFocus<CR>")

-- keymaps for oil.nvim are placed in the oil.lua file
-- placing the keymaps here was casuing a delay in opening oil

-- keymap to remove the highlight on the searched text
vim.keymap.set("n", "<ESC>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- keymaps to easily switch between multiple windows
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- adding a newline while in normal mode
vim.keymap.set("n", "<leader>o", "o<Esc>", { desc = "adding a new line below" })
vim.keymap.set("n", "<leader>O", "O<Esc>", { desc = "adding a new line above" })

-------------------------------------------------------------------------
--- Disabling the arrow keys to get rid of the bad habbit
-------------------------------------------------------------------------
vim.keymap.set({ "n", "i" }, "<Up>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set({ "n", "i" }, "<Down>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set({ "n", "i" }, "<Left>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set({ "n", "i" }, "<Right>", "<Nop>", { noremap = true, silent = true })

-- keymaps to dragging whole selections up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<leader>bc", function()
	local activesBuffers = vim.fn.bufnr("%")
	for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
		if buffer ~= activesBuffers and vim.api.nvim_buf_is_loaded(buffer) then
			if vim.bo[buffer].modified == false then
				vim.api.nvim_buf_delete(buffer, { force = false })
			end
		end
	end
	vim.notify("closed all saved, non-active buffers", vim.log.levels.INFO, { timeout = 1500 })
end)

-------------------------------------------------------------------------
--- Keymap to format the active buffer using prettierd/stylua
-------------------------------------------------------------------------
vim.keymap.set("n", "<leader>p{", function()
	-- Get the current cursor position
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	local filetype = vim.bo.filetype
	local output

	-- Run the formatter on the current buffer
	if filetype == "lua" then
		output = vim.fn.system("stylua -", vim.api.nvim_buf_get_lines(0, 0, -1, false))
	else
		output = vim.fn.system(
			"prettierd --stdin-filepath " .. vim.fn.expand("%:p"),
			vim.api.nvim_buf_get_lines(0, 0, -1, false)
		)
	end

	if vim.v.shell_error == 0 then
		vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n"))
	else
		vim.notify(output, vim.log.levels.ERROR)
	end

	-- Jump the cursor poisition as after the running the formatter the cusror jumps to row 0 and col 0
	vim.api.nvim_win_set_cursor(0, { row, col })
end, { desc = "Run Prettier Formatting" })

-------------------------------------------------------------------------
--- Folding (nvim-ufo)
-------------------------------------------------------------------------
vim.keymap.set("n", "zR", function() require("ufo").openAllFolds() end, { desc = "Open all folds" })
vim.keymap.set("n", "zM", function() require("ufo").closeAllFolds() end, { desc = "Close all folds" })
vim.keymap.set("n", "zr", function() require("ufo").openFoldsExceptKinds() end, { desc = "Open folds except kinds" })
vim.keymap.set("n", "zm", function() require("ufo").closeFoldsWith() end, { desc = "Close folds with level" })
vim.keymap.set("n", "K", function()
	local winid = require("ufo").peekFoldedLinesUnderCursor()
	if not winid then
		vim.lsp.buf.hover()
	end
end, { desc = "Peek fold or LSP hover" })

-------------------------------------------------------------------------
--- Git diff between two commits
-------------------------------------------------------------------------
local gitdiff = require("config.gitdiff")
vim.keymap.set("n", "<leader>gdf", gitdiff.git_diff_file_commits, { desc = "Git diff file commits" })
vim.keymap.set("n", "<leader>gda", gitdiff.git_diff_all_commits, { desc = "Git diff all commits" })
vim.keymap.set("n", "<leader>gdw", gitdiff.git_diff_head, { desc = "Git diff working tree vs HEAD" })

-------------------------------------------------------------------------
--- Bufferline (tab-like buffer navigation)
-------------------------------------------------------------------------
vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer tab" })
vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer tab" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close current buffer tab" })

-- Jump directly to buffer by position (like Ctrl+1..9 in VS Code)
for i = 1, 9 do
	vim.keymap.set("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<CR>", {
		desc = "Go to buffer tab " .. i,
	})
end
