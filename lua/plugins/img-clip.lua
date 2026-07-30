return { -- Obsidian-style clipboard-image paste
	"HakonHarnes/img-clip.nvim",
	event = "VeryLazy",
	-- On Wayland it shells out to wl-paste (wl-clipboard, installed via
	-- modules/packages/utilities.nix). Xwayland/X11 would need xclip instead.
	opts = {
		default = {
			-- Save next to the current file in a per-file assets dir, like Obsidian.
			-- e.g. editing notes/newton-raphson.md -> notes/newton-raphson-assets/2026-07-30-14-05-01.png
			dir_path = function()
				return vim.fn.expand("%:t:r") .. "-assets"
			end,
			relative_to_current_file = true,
			use_absolute_path = false,
			file_name = "%Y-%m-%d-%H-%M-%S",
			prompt_for_file_name = false,
		},
		filetypes = {
			-- render-markdown displays these inline; ![](path) is the standard link.
			markdown = {
				url_encode_path = true,
			},
			-- In .tex, insert a ready-to-compile figure with the graphic path.
			tex = {
				template = [[
\begin{figure}[H]
  \centering
  \includegraphics[width=0.8\textwidth]{$FILE_PATH}
  \caption{$CURSOR}
\end{figure}]],
			},
		},
	},
	keys = {
		{ "<leader>ip", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
	},
}
