return { -- Auto-align markdown tables as you type `|`
	"dhruvasagar/vim-table-mode",
	ft = { "markdown", "text" },
	cmd = { "TableModeToggle", "TableModeEnable", "Tableize" },
	init = function()
		-- Use `|` corners so separators render as markdown (|---|) not the
		-- reStructuredText-style `+---+` default.
		vim.g.table_mode_corner = "|"
	end,
	keys = {
		{ "<leader>tm", "<cmd>TableModeToggle<cr>", desc = "Toggle table mode" },
		{ "<leader>tt", "<cmd>Tableize<cr>", desc = "Tableize selection (CSV/TSV -> table)", mode = { "n", "v" } },
		{ "<leader>tr", "<cmd>TableModeRealign<cr>", desc = "Realign table" },
	},
}
