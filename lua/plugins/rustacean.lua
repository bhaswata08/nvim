return {
	"mrcjkb/rustaceanvim",
	version = "^7",
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
