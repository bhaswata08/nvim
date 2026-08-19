-- Which machine is this config running on?
--
-- On NixOS every LSP server, formatter and CLI comes from the flake
-- (modules/packages/languages.nix, development.nix) and is already on PATH.
-- Mason cannot be used there: it ships prebuilt FHS binaries whose dynamic
-- linker does not exist on NixOS, which is why 7b119a9 dropped it.
--
-- On a plain server none of that exists and nothing is on PATH, so Mason has to
-- install the same set itself (see plugins/mason.lua).
--
-- /etc/NIXOS is written by the NixOS installer and is present on every NixOS
-- machine. Checking for the `nix` binary instead would misfire on the servers
-- that only have Nix the package manager installed under a non-NixOS distro.

local M = {}

M.is_nixos = vim.uv.fs_stat("/etc/NIXOS") ~= nil

--- True when `name` is an executable on PATH.
--- @param name string
--- @return boolean
function M.has(name)
	return vim.fn.executable(name) == 1
end

return M
