return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"mfussenegger/nvim-dap-python",
		"nvim-neotest/nvim-nio",
		"theHamsta/nvim-dap-virtual-text",
	},
	config = function()
		local dap, dapui = require("dap"), require("dapui")
		require("dap-python").setup("uv")
		require("nvim-dap-virtual-text").setup({
			virt_text_pos = "inline",
			commented = true,
			highlight_changed_variables = true,
		})

		dapui.setup()

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

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "dap-terminal",
			callback = function(args)
				vim.keymap.set("n", "i", "<cmd>startinsert<CR>", { buffer = args.buf, silent = true })
				vim.keymap.set("n", "a", "<cmd>startinsert<CR>", { buffer = args.buf, silent = true })
				vim.keymap.set("n", "<CR>", "<cmd>startinsert<CR>", { buffer = args.buf, silent = true })
			end,
		})

		vim.keymap.set("n", "<Leader>Dt", dap.toggle_breakpoint, { desc = "DAP: [t]oggle Breakpoint" })
		vim.keymap.set("n", "<Leader>Dc", dap.continue, { desc = "DAP: [c]continue" })
		vim.keymap.set("n", "<Leader>DB", function()
			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end, { desc = "DAP: Conditional [B]reakpoint" })
		vim.keymap.set("n", "<Leader>Do", dap.step_over, { desc = "DAP: Step [O]ver" })
		vim.keymap.set("n", "<Leader>Di", dap.step_into, { desc = "DAP: Step [I]nto" })
		vim.keymap.set("n", "<Leader>Du", dap.step_out, { desc = "DAP: Step O[u]t / Up" })
		vim.keymap.set("n", "<Leader>Dx", dap.terminate, { desc = "DAP: Terminate ([X])" })
		vim.keymap.set("n", "<Leader>Dr", dap.repl.toggle, { desc = "DAP: Toggle [R]EPL" })
		vim.keymap.set("n", "<Leader>D?", function()
			dap.eval(nil, { "enter = true" })
		end, { desc = "Evaluate expression" })
	end,
}
