local function format_and_copy_diagnostics(diagnostics, description)
	if #diagnostics == 0 then
		print("No " .. string.lower(description) .. " found!")
		return
	end

	local severity_names = {
		[vim.diagnostic.severity.ERROR] = "ERROR",
		[vim.diagnostic.severity.WARN] = "WARN",
		[vim.diagnostic.severity.INFO] = "INFO",
		[vim.diagnostic.severity.HINT] = "HINT",
	}

	local lines = { "Here is the list of " .. string.lower(description) .. " for context:" }

	for _, d in ipairs(diagnostics) do
		local filename = vim.api.nvim_buf_get_name(d.bufnr)
		filename = vim.fn.fnamemodify(filename, ":.")

		local severity = severity_names[d.severity] or "UNKNOWN"
		local line_num = d.lnum + 1
		local col_num = d.col + 1

		local formatted = string.format("[%s] File: %s:%d:%d -> %s", severity, filename, line_num, col_num, d.message)
		table.insert(lines, formatted)
	end

	local final_text = table.concat(lines, "\n")
	vim.fn.setreg("+", final_text)
	print("Copied " .. #diagnostics .. " " .. string.lower(description) .. " to clipboard!")
end

-- ==============================================================================
-- 1. All Workspace Diagnostics
-- ==============================================================================
vim.api.nvim_create_user_command("CopyDiagnosticsAll", function()
	-- Passing 'nil' gets diagnostics across all open buffers
	local diags = vim.diagnostic.get(nil)
	format_and_copy_diagnostics(diags, "Workspace diagnostics")
end, { desc = "Copy ALL workspace diagnostics to clipboard" })

-- ==============================================================================
-- 2. Current Buffer Diagnostics Only
-- ==============================================================================
vim.api.nvim_create_user_command("CopyDiagnosticsBuffer", function()
	-- Passing '0' gets diagnostics for the current active buffer only
	local diags = vim.diagnostic.get(0)
	format_and_copy_diagnostics(diags, "Current buffer diagnostics")
end, { desc = "Copy CURRENT BUFFER diagnostics to clipboard" })

-- ==============================================================================
-- 3. Error Diagnostics Only (Workspace)
-- ==============================================================================
vim.api.nvim_create_user_command("CopyDiagnosticsErrors", function()
	-- Passing 'nil' for all buffers, but filtering specifically for ERROR severity
	local diags = vim.diagnostic.get(nil, { severity = vim.diagnostic.severity.ERROR })
	format_and_copy_diagnostics(diags, "Error diagnostics")
end, { desc = "Copy ERROR diagnostics to clipboard" })
