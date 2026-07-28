return {
	-- Main LSP Configuration.
	-- nvim-lspconfig ships the per-server default configs (cmd/root markers/
	-- filetypes) as `lsp/*.lua` runtime files; we consume them via the native
	-- vim.lsp.config()/vim.lsp.enable() API (Neovim 0.11+) rather than the old
	-- require("lspconfig")[name].setup() framework.
	"neovim/nvim-lspconfig",
	-- Lazy-load LSP only when a real file buffer is opened.
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		-- NixOS note: no Mason. Its prebuilt FHS binaries can't run here, so LSP
		-- servers are installed via Nix (modules/packages/languages.nix) and found
		-- on PATH; they're wired up with the native vim.lsp API below.

		-- Auto-updates imports/paths when files are renamed or moved (e.g. from oil).
		{
			"antosha417/nvim-lsp-file-operations",
			dependencies = { "nvim-lua/plenary.nvim" },
			config = true,
		},

		-- Useful status updates for LSP.
		{
			"j-hui/fidget.nvim",
		},
		-- Allows extra capabilities provided by blink.cmp
		"saghen/blink.cmp",
	},
	config = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				-- Rename the variable under your cursor.
				--  Most Language Servers support renaming across files, etc.
				map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

				-- Execute a code action, usually your cursor needs to be on top of an error
				-- or a suggestion from your LSP for this to activate.
				map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

				local fzf = require("fzf-lua")

				-- Find references for the word under your cursor.
				map("grr", fzf.lsp_references, "[G]oto [R]eferences")

				-- Jump to the implementation of the word under your cursor.
				--  Useful when your language has ways of declaring types without an actual implementation.
				map("gri", fzf.lsp_implementations, "[G]oto [I]mplementation")

				-- Jump to the definition of the word under your cursor.
				--  This is where a variable was first declared, or where a function is defined, etc.
				--  To jump back, press <C-t>.
				map("grd", fzf.lsp_definitions, "[G]oto [D]efinition")

				-- WARN: This is not Goto Definition, this is Goto Declaration.
				--  For example, in C this would take you to the header.
				map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

				-- Fuzzy find all the symbols in your current document.
				--  Symbols are things like variables, functions, types, etc.
				map("gO", fzf.lsp_document_symbols, "Open Document Symbols")

				-- Fuzzy find all the symbols in your current workspace.
				--  Similar to document symbols, except searches over your entire project.
				map("gW", fzf.lsp_live_workspace_symbols, "Open Workspace Symbols")

				-- Jump to the type of the word under your cursor.
				--  Useful when you're not sure what type a variable is and you want to see
				--  the definition of its *type*, not where it was *defined*.
				map("grt", fzf.lsp_typedefs, "[G]oto [T]ype Definition")

				-- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
				---@param client vim.lsp.Client
				---@param method vim.lsp.protocol.Method
				---@param bufnr? integer some lsp support methods only in specific files
				---@return boolean
				local function client_supports_method(client, method, bufnr)
					if vim.fn.has("nvim-0.11") == 1 then
						return client:supports_method(method, bufnr)
					else
						return client.supports_method(method, { bufnr = bufnr })
					end
				end

				-- The following two autocommands are used to highlight references of the
				-- word under your cursor when your cursor rests there for a little while.
				--    See `:help CursorHold` for information about when this is executed
				--
				-- When you move your cursor, the highlights will be cleared (the second autocommand).
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if
					client
					and client_supports_method(
						client,
						vim.lsp.protocol.Methods.textDocument_documentHighlight,
						event.buf
					)
				then
					local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})

					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
						end,
					})
				end

				-- The following code creates a keymap to toggle inlay hints in your
				-- code, if the language server you are using supports them
				--
				-- This may be unwanted, since they displace some of your code
				if
					client
					and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
				then
					map("<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
					end, "[T]oggle Inlay [H]ints")
				end
			end,
		})

		-- Diagnostic Config
		-- See :help vim.diagnostic.Opts
		vim.diagnostic.config({
			update_in_insert = false,
			severity_sort = true,
			float = { border = "rounded", source = "if_many" },
			underline = { severity = vim.diagnostic.severity.ERROR },
			signs = vim.g.have_nerd_font and {
				text = {
					[vim.diagnostic.severity.ERROR] = "󰅚 ",
					[vim.diagnostic.severity.WARN] = "󰀪 ",
					[vim.diagnostic.severity.INFO] = "󰋽 ",
					[vim.diagnostic.severity.HINT] = "󰌶 ",
				},
			} or {},
			virtual_text = {
				source = "if_many",
				spacing = 2,
				format = function(diagnostic)
					local diagnostic_message = {
						[vim.diagnostic.severity.ERROR] = diagnostic.message,
						[vim.diagnostic.severity.WARN] = diagnostic.message,
						[vim.diagnostic.severity.INFO] = diagnostic.message,
						[vim.diagnostic.severity.HINT] = diagnostic.message,
					}
					return diagnostic_message[diagnostic.severity]
				end,
			},
		})

		-- LSP servers and clients are able to communicate to each other what features they support.
		--  By default, Neovim doesn't support everything that is in the LSP specification.
		--  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
		--  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		-- Enable the following language servers
		--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
		--
		--  Add any additional override configuration in the following tables. Available keys are:
		--  - cmd (table): Override the default command used to start the server
		--  - filetypes (table): Override the default list of associated filetypes for the server
		--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
		--  - settings (table): Override the default settings passed when initializing the server.
		--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
		local servers = {
			-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs

			basedpyright = {
				analysis = {
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
				},

				settings = {
					python = {
						analysis = {
							typeCheckingMode = "recommended",
						},
					},
				},
			},
			nixd = {},
			-- pyright = {
			-- 	settings = {
			-- 		python = {
			-- 			analysis = {
			-- 				typeCheckingMode = "strict",
			-- 			},
			-- 		},
			-- 	},
			-- },
			dockerls = {},
			jsonls = {},
			yamlls = {},
			-- ty = {},
			tinymist = {
				settings = {
					formatterMode = "typstyle",
					exportPdf = "never",
				},
			},
			ruff = {},
			lua_ls = {
				-- cmd = { ... },
				-- filetypes = { ... },
				-- capabilities = {},
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
						runtime = { version = "LuaJIT" },
						workspace = {
							checkThirdParty = false,
							library = {
								"${3rd}/luv/library",
								unpack(vim.api.nvim_get_runtime_file("", true)),
							},
						},
						-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
						diagnostics = { disable = { "missing-fields" } },
						format = {
							enable = false,
						},
					},
				},
			},
			-- rust_analyzer is configured by rustaceanvim (see rustacean.lua);
			-- do NOT also set it up here or the client attaches twice.
			-- bacon_ls = {},
			-- clangd = {},
			--
			-- gopls = {},
			-- mojo = {
			-- 	default_config = {
			-- 		cmd = { "mojo-lsp-server" },
			-- 		filetypes = { "mojo" },
			-- 		root_dir = function(fname)
			-- 			return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
			-- 		end,
			-- 		single_file_support = true,
			-- 	},
			-- 	docs = {
			-- 		description = [[
			-- 			https://github.com/modularml/mojo
			--
			-- 			`mojo-lsp-server` can be installed [via Modular](https://developer.modular.com/download)
			--
			-- 			Mojo is a new programming language that bridges the gap between research and production by combining Python syntax and ecosystem with systems programming and metaprogramming features.
			-- 			]],
			-- 	},
			-- },
			-- basedpyright = {
			-- 	settings = {
			-- 		python = {
			-- 			analysis = {
			-- 				extraPaths = { vim.fn.expand("$HOME/.rye/shims") },
			-- 				autoSearchPaths = true,
			-- 				useLibraryCodeForTypes = true,
			-- 			},
			-- 		},
			-- 	},
			-- 	before_init = function(_, config)
			-- 		-- Try to find and use the Rye environment's Python
			-- 		local rye_path = vim.fn.getcwd() .. "/.venv/bin/python"
			-- 		if vim.fn.filereadable(rye_path) == 1 then
			-- 			config.settings.python.pythonPath = rye_path
			-- 		end
			-- 	end,
			-- },
			-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
			--
			-- Some languages (like typescript) have entire language plugins that can be useful:
			--    https://github.com/pmizio/typescript-tools.nvim
			--
			-- But for many setups, the LSP (`ts_ls`) will work just fine
			-- ts_ls = {},
			--
			-- pylsp = {
			-- 	settings = {
			-- 		pylsp = {
			-- 			plugins = {
			-- 				pyflakes = { enabled = false },
			-- 				pycodestyle = { enabled = false },
			-- 				autopep8 = { enabled = false },
			-- 				yapf = { enabled = false },
			-- 				mccabe = { enabled = false },
			-- 				pylsp_mypy = { enabled = true },
			-- 				pylsp_black = { enabled = false },
			-- 				pylsp_isort = { enabled = false },
			-- 				jedi_completion = { enabled = false },
			-- 			},
			-- 		},
			-- 	},
			-- },
			ty = {},
			-- ty = {
			--
			-- 	init_options = {
			-- 		settings = {
			-- 			-- ty language server settings go here
			-- 			-- Example:
			-- 			-- ["ty.enable"] = true,
			-- 			-- ["ty.diagnostics.enable"] = true,
			-- 			-- ["ty.diagnostics.level"] = "warning",
			-- 		},
			-- 	},
			-- 	-- Assuming 'ty' typically operates on Python files, similar to pylsp or ruff
			-- 	filetypes = { "python" },
			-- },
		}

		-- LSP servers come from Nix (see modules/packages/languages.nix) and are
		-- available on PATH.
		--
		-- Broadcast the blink.cmp capabilities to every server via the wildcard
		-- config, then apply each server's overrides on top of the nvim-lspconfig
		-- defaults and enable them (native vim.lsp API, Neovim 0.11+).
		vim.lsp.config("*", { capabilities = capabilities })

		for server_name, server in pairs(servers) do
			vim.lsp.config(server_name, server)
		end

		vim.lsp.enable(vim.tbl_keys(servers))
	end,
}
