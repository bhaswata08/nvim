return {
	"nvimtools/none-ls.nvim",
	dependencies = {
		"nvimtools/none-ls-extras.nvim",
	},
	config = function()
		local null_ls = require("null-ls")
		local formatting = null_ls.builtins.formatting -- to setup formatters
		local diagnostics = null_ls.builtins.diagnostics -- to setup linters

		-- NixOS: formatters/linters (prettier, stylua, shfmt, checkmake, ruff)
		-- are installed via Nix and found on PATH. We do NOT use mason-null-ls to
		-- install them, since Mason's FHS binaries can't run on NixOS.

		local sources = {
			diagnostics.checkmake,
			diagnostics.markdownlint_cli2.with({
				-- Use the in-repo config regardless of cwd, so rules are consistent on every machine.
				extra_args = { "--config", vim.fn.stdpath("config") .. "/.markdownlint.jsonc" },
			}),
			formatting.prettier.with({ filetypes = { "html", "json", "yaml", "markdown" } }),
			formatting.stylua,
			formatting.shfmt.with({ args = { "-i", "4" } }),
			require("none-ls.formatting.ruff").with({ extra_args = { "--extend-select", "I" } }),
			require("none-ls.formatting.ruff_format"),
		}

		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
		null_ls.setup({
			debug = true, -- Enable debug mode. Inspect logs with :NullLsLog.
			sources = sources,
			-- you can reuse a shared lspconfig on_attach callback here
			on_attach = function(client, bufnr)
				if client:supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({
								async = false,
								-- filter = function(c)
								-- 	return c.name == "null-ls"
								-- end,
							})
						end,
					})
				end
			end,
		})
	end,
}
