return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"theHamsta/nvim-dap-virtual-text",
		"mason-org/mason.nvim",
	},
	keys = {
		{
			"<leader>b",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Toggle breakpoint",
		},
		{
			"<F1>",
			function()
				require("dap").continue()
			end,
			desc = "DAP continue",
		},
		{
			"<F2>",
			function()
				require("dap").step_over()
			end,
			desc = "DAP step over",
		},
		{
			"<F3>",
			function()
				require("dap").step_into()
			end,
			desc = "DAP step into",
		},
		{
			"<F4>",
			function()
				require("dap").step_out()
			end,
			desc = "DAP step out",
		},
		{
			"<F6>",
			function()
				require("dap").step_back()
			end,
			desc = "DAP step back",
		},
		{
			"<F7>",
			function()
				require("dap").restart()
			end,
			desc = "DAP restart",
		},
		{
			"<leader><F7>",
			function()
				require("dap").terminate()
			end,
			desc = "DAP terminate",
		},
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		require("nvim-dap-virtual-text").setup({})
		dapui.setup()

		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = vim.fn.exepath("codelldb"),
				args = { "--port", "${port}" },
			},
		}

		dap.configurations.cpp = {
			{
				name = "Launch",
				type = "codelldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
			},
		}
		dap.configurations.c = dap.configurations.cpp

		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end
	end,
}
