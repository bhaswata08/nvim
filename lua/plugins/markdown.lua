return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {
		-- Renders $$..$$ / $..$ math to unicode. `latex2unicode` (Nix-provided, see
		-- modules/packages/latex2unicode.py) lays matrices and \frac out in 2D and runs
		-- unicodeit -> latex2text on the leaves, so sub/superscripts (θ₀, x², ℒ⁽ᵏ⁾) render
		-- too. The list is a fallback chain: until `just switch` puts latex2unicode on
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
