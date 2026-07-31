return { -- Auto-continue bullets/numbered lists, renumber, toggle checkboxes
	"gaoDean/autolist.nvim",
	ft = { "markdown", "text", "tex", "plaintex" },
	config = function()
		require("autolist").setup()

		-- Keymaps are buffer-local so <CR>/o/O/dd keep their normal meaning in
		-- code buffers (mapping <CR> globally would hijack Enter everywhere).
		local function set_keys(buf)
			local map = function(mode, lhs, rhs)
				vim.keymap.set(mode, lhs, rhs, { buffer = buf })
			end
			map("i", "<tab>", "<cmd>AutolistTab<cr>") -- indent list item
			map("i", "<s-tab>", "<cmd>AutolistShiftTab<cr>") -- dedent list item
			map("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>") -- continue list on Enter
			map("n", "o", "o<cmd>AutolistNewBullet<cr>")
			map("n", "O", "O<cmd>AutolistNewBulletBefore<cr>")
			map("n", "<CR>", "<cmd>AutolistToggleCheckbox<cr><CR>") -- toggle [ ] / [x]
			map("n", "<C-r>", "<cmd>AutolistRecalculate<cr>") -- renumber ordered list
			-- Recalculate numbering after structural edits.
			map("n", ">>", ">><cmd>AutolistRecalculate<cr>")
			map("n", "<<", "<<<cmd>AutolistRecalculate<cr>")
			map("n", "dd", "dd<cmd>AutolistRecalculate<cr>")
			map("v", "d", "d<cmd>AutolistRecalculate<cr>")
		end

		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "markdown", "text", "tex", "plaintex" },
			group = vim.api.nvim_create_augroup("autolist_keys", { clear = true }),
			callback = function(ev)
				set_keys(ev.buf)
			end,
		})
		-- The FileType event for the buffer that lazy-loaded us already fired, so
		-- apply to it directly too.
		set_keys(0)
	end,
}
