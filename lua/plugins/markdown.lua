return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {
		-- Renders $$..$$ / $..$ math to unicode. `latex2unicode` (Nix-provided, see
		-- modules/packages/latex2unicode) lays matrices, \frac and limits out in 2D,
		-- and still renders sub/superscripts (θ₀, x², ℒ⁽ᵏ⁾). render-markdown converts
		-- every on-screen equation while blocking the UI thread, so the converter is a
		-- native binary; the old Python one spent ~50x longer starting up than converting.
		-- The list is a fallback chain: until `just switch` puts latex2unicode on
		-- PATH, plain latex2text is used. Needs the `latex` parser.
		latex = {
			enabled = true,
			converter = { "latex2unicode", "latex2text" },
		},
		completions = {
			lsp = {
				enabled = true,
			},
		},
	},
}
