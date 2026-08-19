-- Mason: tooling for non-NixOS machines only (see core/platform.lua).
--
-- On NixOS this spec is disabled and the flake keeps providing the tools.
-- Everywhere else Mason installs the same set and prepends its bin directory to
-- PATH, so lsp.lua, autoformatting.lua and treesitter.lua all find their
-- binaries without knowing where they came from.
--
-- Mason 2.x lives under `mason-org/*`; the `williamboman/*` repos and the
-- `handlers` API this config used before 7b119a9 are both gone.
--
-- mason-lspconfig is deliberately NOT used. The only thing it would do here is
-- `ensure_installed`, since lsp.lua already calls vim.lsp.enable() for exactly
-- the servers it configures (so `automatic_enable` would just attach a second
-- client to every buffer). And its ensure_installed is a no-op in headless
-- Neovim — mason-lspconfig/init.lua guards it with `not platform.is_headless` —
-- which silently skips every server on `nvim --headless`. Driving mason-registry
-- directly avoids that, needs no extra plugin, and keeps one list instead of two.

local platform = require("core.platform")

-- Mason package names. The comment after each is the nvim-lspconfig server name
-- it backs, which is how lsp.lua refers to it; keep the two lists in sync.
--
-- Not here on purpose:
--   nixd          - not in the Mason registry, and a machine with no Nix has no
--                   .nix files to edit anyway.
--   rust_analyzer - configured by rustaceanvim (rustacean.lua), not lsp.lua, but
--                   the binary still has to exist, so it is listed below.
local packages = {
	-- LSP servers
	"basedpyright", -- basedpyright
	"marksman", -- marksman
	"dockerfile-language-server", -- dockerls
	"json-lsp", -- jsonls
	"yaml-language-server", -- yamlls
	"tinymist", -- tinymist
	"ruff", -- ruff
	"lua-language-server", -- lua_ls
	"ty", -- ty
	"rust-analyzer", -- rustaceanvim

	-- nvim-treesitter's `main` branch compiles every parser with this CLI.
	-- Without it there is no syntax highlighting at all (see treesitter.lua).
	"tree-sitter-cli",

	-- none-ls sources (see autoformatting.lua)
	"stylua",
	"prettier",
	"shfmt",
	"checkmake",
	"markdownlint-cli2",
}

--- Install anything in `packages` that Mason does not have yet.
--- mason.nvim has no `ensure_installed` of its own, and mason-tool-installer is
--- a third-party plugin of unclear upkeep against Mason 2.x, so use the registry
--- API directly.
local function install_missing()
	local registry = require("mason-registry")

	registry.refresh(function()
		for _, name in ipairs(packages) do
			if not registry.has_package(name) then
				-- Reached if a package is renamed or dropped upstream. Say so loudly:
				-- the alternative is a tool that silently never installs again.
				vim.notify(("mason: unknown package %q"):format(name), vim.log.levels.WARN)
			else
				local pkg = registry.get_package(name)
				if not pkg:is_installed() and not pkg:is_installing() then
					vim.notify(("mason: installing %s"):format(name), vim.log.levels.INFO)
					pkg:install()
				end
			end
		end
	end)
end

return {
	"mason-org/mason.nvim",
	enabled = not platform.is_nixos,
	-- Not lazy, and ahead of everything else: mason.setup() is what prepends
	-- ~/.local/share/nvim/mason/bin to PATH, and treesitter.lua (also
	-- lazy = false) needs `tree-sitter` on PATH by the time it runs.
	lazy = false,
	priority = 1000,
	opts = {},
	config = function(_, opts)
		require("mason").setup(opts)
		install_missing()
	end,
}
