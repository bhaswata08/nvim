return {
	"boltlessengineer/bufterm.nvim",
	config = function()
		local opts = { noremap = true, silent = true }
		vim.keymap.set("n", "<C-`>", "<cmd>split<CR><cmd>BufTermEnter<CR><cmd>startinsert<CR>", opts) -- open a terminal vscode style and put in insert mode
		vim.keymap.set("t", "<C-`>", "<C-\\><C-n><cmd>hide<CR>", opts) -- toggle terminal visibility
		vim.keymap.set("n", "<leader>tn", "<cmd>BufTermNext<CR><cmd>startinsert<CR>", opts) -- Next terminal and insert mode
		vim.keymap.set("n", "<leader>tp", "<cmd>BufTermPrev<CR><cmd>startinsert<CR>", opts) -- Previous terminal and insert mode
		vim.keymap.set("n", "<leader>to", "<cmd>terminal<CR><cmd>startinsert<CR>", opts) -- New terminal and insert mode
		vim.keymap.set("n", "<leader>tq", "<cmd>bdelete!<CR>", opts)
		vim.keymap.set("t", "<leader>tq", "<C-\\><C-n><cmd>bdelete!<CR>", opts)
		vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)

		require("bufterm").setup()
	end,
}
