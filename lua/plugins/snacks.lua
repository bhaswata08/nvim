return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			bigfile = { enabled = true },
			dashboard = { enabled = true },
			explorer = {
				enabled = true,
			},
			-- indent guides are drawn by indent-blankline... which is gone now,
			-- so snacks owns them. Only one of the two may be on at a time.
			indent = { enabled = true },
			input = { enabled = true },
			-- Required by explorer above. fzf-lua stays the picker for LSP and
			-- file search (see lsp.lua and fzf.lua); this one is not bound to keys.
			picker = { enabled = true },
			-- notifier off: noice already routes notifications to nvim-notify.
			-- Turning this on gives two popup stacks for the same messages.
			notifier = { enabled = false },
			quickfile = { enabled = true },
			scope = { enabled = true },
			scroll = { enabled = true },
			-- statuscolumn off: comfy-line-numbers owns the number column.
			statuscolumn = { enabled = false },
			words = { enabled = true },
		},
		keys = {
			{
				"<leader>e",
				function()
					Snacks.explorer()
				end,
				desc = "Explorer",
			},
		},
	},
}
