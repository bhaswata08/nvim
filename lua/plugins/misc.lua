-- Standalone plugins with less than 10 lines of config go here
return {
	{
		-- Tmux & split window navigation
		"christoomey/vim-tmux-navigator",
	},
	{
		-- Herdr pane <-> nvim window navigation on <C-h/j/k/l>. Owns those maps itself
		-- (and sets vim.g.tmux_navigator_no_mappings), delegating to vim-tmux-navigator
		-- under tmux and to plain wincmd when neither multiplexer is running.
		-- `build = false`: the helper binary comes from Nix (modules/packages/external.nix)
		-- rather than the plugin's own `cargo build`, so `helper` names it on PATH.
		"devxplay/herdr.nvim",
		lazy = false,
		build = false,
		opts = { helper = "herdr-navigator" },
	},
	{
		-- Detect tabstop and shiftwidth automatically
		"tpope/vim-sleuth",
	},
	{
		-- Powerful Git integration for Vim
		"tpope/vim-fugitive",
	},
	{
		-- GitHub integration for vim-fugitive
		"tpope/vim-rhubarb",
	},
	{
		-- Hints keybinds
		"folke/which-key.nvim",
	},
	{
		-- Autoclose parentheses, brackets, quotes, etc.
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		opts = {},
	},
	{
		-- Highlight todo, notes, etc in comments
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
	{
		-- High-performance color highlighter
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	},
	{
		"cordx56/rustowl",
		version = "*", -- Latest stable version
		build = "cargo install rustowl",
		lazy = false, -- This plugin is already lazy
		opts = {},
	},
	{
		"rmagatti/auto-session",
		lazy = false,

		---enables autocomplete for opts
		---@module "auto-session"
		---@type AutoSession.Config
		opts = {
			suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
			-- log_level = 'debug',
		},
	},
	{
		"atiladefreitas/dooing",
		config = function()
			require("dooing").setup({})
		end,
	},
	{
		"mluders/comfy-line-numbers.nvim",
		config = function()
			require("comfy-line-numbers").setup()
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
	},
	{
		"3rd/image.nvim",
		build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
		opts = {
			processor = "magick_cli",
		},
	},
}
