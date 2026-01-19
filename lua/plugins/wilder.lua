return {
	"gelguy/wilder.nvim",
	lazy = false,
	config = function()
		require("wilder").setup({ modes = { ":", "/", "?" } })
	end,
}
