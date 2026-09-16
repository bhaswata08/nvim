require("core.options")
require("core.keymaps")
require("core.custom")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Treesitter folds (Neovim builtin; nvim-treesitter `main` has no foldexpr of its own)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 1 -- Start with top-level folds closed
vim.opt.foldenable = false

require("lazy").setup({
	require("plugins.autocompletion"),
	require("plugins.autoformatting"),
	require("plugins.autolist"),
	require("plugins.bufferline"),
	require("plugins.bufterm"),
	require("plugins.colortheme"),
	require("plugins.comment"),
	require("plugins.debugging"),
	require("plugins.flash"),
	require("plugins.fzf"),
	require("plugins.gitgraph"),
	require("plugins.gitsigns"),
	require("plugins.gx"),
	require("plugins.hardtime"),
	require("plugins.img-clip"),
	require("plugins.lsp"),
	require("plugins.lualine"),
	require("plugins.markdown"),
	require("plugins.mason"),
	require("plugins.mini"),
	require("plugins.misc"),
	require("plugins.noice"),
	require("plugins.oil"),
	require("plugins.remote-nvim"),
	require("plugins.rustacean"),
	require("plugins.snacks"),
	require("plugins.table-mode"),
	require("plugins.todo-comments"),
	require("plugins.treesitter"),
	require("plugins.tts"),
	require("plugins.typst"),
})

require("luasnippets.diagnostics")
require("luasnippets.markdown")
