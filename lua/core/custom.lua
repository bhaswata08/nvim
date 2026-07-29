-- The Nix-provided latex grammar (0.6.0) is newer than the latex queries shipped
-- with nvim-treesitter's archived master branch, which reference removed nodes like
-- `curly_group_text` -> "Impossible pattern" errors while highlighting $$ math.
-- render-markdown conceals/converts the math anyway, so blank the mismatched latex
-- highlight/injection queries to silence it (the parser itself is still used).
vim.treesitter.query.set("latex", "highlights", "")
vim.treesitter.query.set("latex", "injections", "")

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
