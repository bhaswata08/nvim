return {
	"numToStr/Comment.nvim",
	config = function()
		require("Comment").setup({
			-- Optional configuration
			mappings = {
				basic = true,
				extra = true,
			},
		})
		-- Add your custom Ctrl+/ mapping
		vim.keymap.set("n", "<C-/>", "gcc", { remap = true })
		vim.keymap.set("v", "<C-/>", "gc", { remap = true })
		-- Some terminals send <C-_> for <C-/>
		vim.keymap.set("n", "<C-_>", "gcc", { remap = true })
		vim.keymap.set("v", "<C-_>", "gc", { remap = true })
	end,
}
