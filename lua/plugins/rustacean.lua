return {
	"mrcjkb/rustaceanvim",
	-- ^7 held this at v7.1.9 for six months. The only breaking changes since
	-- are dropping Neovim 0.11 (we run 0.12) and dropping .vscode/settings.json
	-- support (unused here), so neither affects this config.
	version = "^9",
	lazy = false,

	init = function()
		-- Get capabilities from blink.cmp
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		vim.g.rustaceanvim = {
			server = {
				capabilities = capabilities,
			},
		}
	end,
}
