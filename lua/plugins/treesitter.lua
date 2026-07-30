return { -- Highlight, edit, and navigate code
	"nvim-treesitter/nvim-treesitter",
	branch = "master", -- stable API: ensure_installed/auto_install/highlight actually apply
	build = ":TSUpdate",
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
		-- master's custom TS predicates/directives assume the pre-0.11 `match` shape;
		-- re-register them array-tolerantly so markdown injections don't crash.
		require("core.ts-directive-compat")
	end,
	-- [[ Configure Treesitter ]] See `:help nvim-treesitter`
	opts = {
		ensure_installed = {
			"lua",
			"python",
			"javascript",
			"typescript",
			"vimdoc",
			"vim",
			"regex",
			"terraform",
			"sql",
			"dockerfile",
			"toml",
			"json",
			"java",
			"groovy",
			"go",
			"gitignore",
			"graphql",
			"yaml",
			"make",
			"cmake",
			"markdown",
			"markdown_inline",
			-- latex parser is provided prebuilt via Nix (configs/nvim.nix); the
			-- tree-sitter 0.26 CLI can't run master's generate step for it.
			"bash",
			"tsx",
			"css",
			"html",
			"rust",
		},
		-- Autoinstall languages that are not installed
		auto_install = true,
		highlight = {
			enable = true,
		},
		-- Folding is driven by foldexpr in init.lua; master's configs has no `fold` module.
	},
	-- There are additional nvim-treesitter modules that you can use to interact
	-- with nvim-treesitter. You should go explore a few and see what interests you:
	--
	--    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
	--    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
	--    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
}
