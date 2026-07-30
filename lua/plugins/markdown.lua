return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {
		-- Renders $$..$$ / $..$ math to unicode. `latex2unicode` (Nix-provided wrapper)
		-- pipes unicodeit -> latex2text so sub/superscripts (θ₀, x², ℒ⁽ᵏ⁾) render too,
		-- which plain latex2text can't. The list is a fallback chain: until `just switch`
		-- puts latex2unicode on PATH, plain latex2text is used. Needs the `latex` parser.
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
