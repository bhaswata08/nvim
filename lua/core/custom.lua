-- Spell check for prose filetypes (uses ~/.config/nvim/spell/en.utf-8.add).
-- z= to see suggestions, zg to add a word, ]s / [s to jump between misspellings.
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "text", "gitcommit", "typst" },
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.spelllang = "en_us"
	end,
})

vim.keymap.set("n", "<leader>co", ":vsplit | terminal opencode<CR>", { noremap = true, silent = true }) -- Opencode
vim.keymap.set("n", "<leader>bd", function()
	vim.cmd("Bdelete!") -- Execute the first Ex command
	vim.cmd("close") -- Execute the second Ex command
end, { noremap = true, silent = true, desc = "Delete buffer and close window" })
