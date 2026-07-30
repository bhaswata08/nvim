-- Compatibility shim for nvim-treesitter's *archived* master branch on Neovim >=0.11.
--
-- Neovim changed the `match` argument handed to treesitter predicate/directive
-- handlers from `table<integer, TSNode>` to `table<integer, TSNode[]>` (a list of
-- nodes per capture). nvim-treesitter master still does `local node = match[id]`
-- and then `node:range()` / `node:type()`, so it now calls a method on a plain
-- Lua table and crashes with `attempt to call method 'range' (a nil value)`.
--
-- This breaks, among other things, markdown code-fence injections
-- (`#set-lang-from-info-string!`), which surfaces via image.nvim's
-- `query_buffer_images` and snacks.nvim's scope detection. Re-register the six
-- affected handlers with array-tolerant node extraction. Everything else is a
-- faithful copy of nvim-treesitter's own logic.
local query = require("vim.treesitter.query")
require("nvim-treesitter.query_predicates") -- ensure the originals are registered first, so ours win

local opts = { force = true }

-- Neovim now passes each capture as a list of nodes; the affected queries never
-- use quantifiers, so there is exactly one. Fall back to the value itself for the
-- pre-0.11 single-node form, keeping this safe on older Neovim too.
local function node_at(match, id)
	local v = match[id]
	if type(v) == "table" then
		return v[#v]
	end
	return v
end

local function err(str)
	vim.api.nvim_echo({ { str, "ErrorMsg" } }, true, {})
end

local function valid_args(name, pred, count, strict_count)
	local arg_count = #pred - 1
	if strict_count then
		if arg_count ~= count then
			err(string.format("%s must have exactly %d arguments", name, count))
			return false
		end
	elseif arg_count < count then
		err(string.format("%s must have at least %d arguments", name, count))
		return false
	end
	return true
end

-- ── predicates ────────────────────────────────────────────────────────────────

query.add_predicate("nth?", function(match, _pattern, _bufnr, pred)
	if not valid_args("nth?", pred, 2, true) then
		return
	end
	local node = node_at(match, pred[2])
	local n = tonumber(pred[3])
	if node and node:parent() and node:parent():named_child_count() > n then
		return node:parent():named_child(n) == node
	end
	return false
end, opts)

query.add_predicate("is?", function(match, _pattern, bufnr, pred)
	if not valid_args("is?", pred, 2) then
		return
	end
	local locals = require("nvim-treesitter.locals")
	local node = node_at(match, pred[2])
	local types = { unpack(pred, 3) }
	if not node then
		return true
	end
	local _, _, kind = locals.find_definition(node, bufnr)
	return vim.tbl_contains(types, kind)
end, opts)

query.add_predicate("kind-eq?", function(match, _pattern, _bufnr, pred)
	if not valid_args(pred[1], pred, 2) then
		return
	end
	local node = node_at(match, pred[2])
	local types = { unpack(pred, 3) }
	if not node then
		return true
	end
	return vim.tbl_contains(types, node:type())
end, opts)

-- ── directives ──────────────────────────────────────────────────────────────

local html_script_type_languages = {
	["importmap"] = "json",
	["module"] = "javascript",
	["application/ecmascript"] = "javascript",
	["text/ecmascript"] = "javascript",
}

local non_filetype_match_injection_language_aliases = {
	ex = "elixir",
	pl = "perl",
	sh = "bash",
	uxn = "uxntal",
	ts = "typescript",
}

local function get_parser_from_markdown_info_string(injection_alias)
	local m = vim.filetype.match({ filename = "a." .. injection_alias })
	return m or non_filetype_match_injection_language_aliases[injection_alias] or injection_alias
end

query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
	local node = node_at(match, pred[2])
	if not node then
		return
	end
	local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
	local configured = html_script_type_languages[type_attr_value]
	if configured then
		metadata["injection.language"] = configured
	else
		local parts = vim.split(type_attr_value, "/", {})
		metadata["injection.language"] = parts[#parts]
	end
end, opts)

query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
	local node = node_at(match, pred[2])
	if not node then
		return
	end
	local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()
	metadata["injection.language"] = get_parser_from_markdown_info_string(injection_alias)
end, opts)

query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
	local id = pred[2]
	local node = node_at(match, id)
	if not node then
		return
	end
	local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ""
	if not metadata[id] then
		metadata[id] = {}
	end
	metadata[id].text = string.lower(text)
end, opts)
