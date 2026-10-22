return {
	"chrishrb/gx.nvim",
	-- Would open the browser on the server. `cond` rather than `enabled` keeps the
	-- plugin in lazy-lock.json when synced on a server.
	cond = not require("core.platform").is_remote,
	keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } } },
	cmd = { "Browse" },
	init = function()
		vim.g.netrw_nogx = 1 -- disable netrw gx
	end,
	dependencies = { "nvim-lua/plenary.nvim" }, -- Required for Neovim < 0.10.0
	-- config = true, -- default settings
	submodules = false,
	config = function()
		require("gx").setup({
			handler_options = {
				search_engine = "duckduckgo",
			},
		})
	end,
}
