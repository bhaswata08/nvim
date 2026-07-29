return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {
		-- Renders $$..$$ / $..$ math via the `latex2text` binary (pylatexenc).
		-- Requires the `latex` treesitter parser to be installed.
		latex = {
			enabled = true,
			converter = "latex2text",
		},
		completions = {
			lsp = {
				enabled = true,
			},
		},
	},
}
