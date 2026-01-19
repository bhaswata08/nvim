vim.keymap.set("n", "<leader>co", ":vsplit | terminal opencode<CR>", { noremap = true, silent = true }) -- Opencode
vim.keymap.set("n", "<leader>bd", function()
	vim.cmd("Bdelete!") -- Execute the first Ex command
	vim.cmd("close") -- Execute the second Ex command
end, { noremap = true, silent = true, desc = "Delete buffer and close window" })
