return { -- Highlight, edit, and navigate code
	"nvim-treesitter/nvim-treesitter",
	branch = "main", -- the rewrite: compatible with Neovim 0.11+; master is archived
	lazy = false, -- load at startup so the FileType highlight autocmd is registered early
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")

		-- Default install_dir is stdpath("data")/site (~/.local/share/nvim/site), which
		-- setup() also prepends to runtimepath. That's the same dir where Nix drops the
		-- prebuilt latex parser (configs/nvim.nix), so everything colocates on rtp.
		ts.setup()

		-- Parsers we want available on every machine. On `main` there is no
		-- `ensure_installed`/`auto_install`; we install explicitly (async — first run
		-- compiles them). `latex` (for render-markdown $ math) installs cleanly here too:
		-- its generate step only failed on the archived master branch, not on `main`.
		local want = {
			"lua",
			"python",
			"javascript",
			"typescript",
			"tsx",
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
			"latex",
			"bash",
			"css",
			"html",
			"rust",
		}
		local installed = ts.get_installed("parsers")
		local missing = vim.tbl_filter(function(lang)
			return not vim.tbl_contains(installed, lang)
		end, want)
		if #missing > 0 then
			-- `main` compiles every parser with the tree-sitter CLI. Without it each
			-- install fails with a bare ENOENT and you get an editor with no
			-- highlighting and no obvious reason why, so say it once instead.
			-- NixOS gets the CLI from languages.nix, everywhere else from Mason
			-- (plugins/mason.lua), which may still be installing it on first run.
			if require("core.platform").has("tree-sitter") then
				ts.install(missing)
			else
				vim.notify(
					"tree-sitter CLI not on PATH: no parsers can be compiled, so syntax "
						.. "highlighting is off. Wait for Mason to finish installing "
						.. "tree-sitter-cli, then restart Neovim.",
					vim.log.levels.WARN
				)
			end
		end

		-- `main` does not enable highlighting automatically. Start it for any buffer
		-- whose filetype has a parser available (installed, or the Nix-provided latex).
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
			callback = function(args)
				-- pcall so filetypes without a parser just fall back to no highlighting.
				pcall(vim.treesitter.start, args.buf)
			end,
		})
	end,
}
