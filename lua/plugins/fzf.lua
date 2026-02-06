return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local fzf = require("fzf-lua")

		fzf.setup({
			-- Replicating your layout: Results on left, Preview on right
			winopts = {
				height = 0.85,
				width = 0.80,
				preview = {
					layout = "flex", -- Switches to vertical split on small screens
					horizontal = "right:50%",
				},
			},
			-- Equivalent to your file_ignore_patterns
			files = {
				fd_opts = [[--color=never --type f --hidden --follow --exclude .git --exclude node_modules --exclude .venv]],
			},
			grep = {
				-- The "-e" at the end is crucial to prevent the "No such file" error
				rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
				rg_glob = true, -- Enables the "glob separator" (query -- *.lua)
			},
			-- Replicating your telescope-ui-select behavior
			ui_select = function(opts)
				return require("fzf-lua").register_ui_select(opts, {
					winopts = { vertical = "down:15%", width = 0.5 }, -- Dropdown-ish look
				})
			end,
			keymap = {
				-- Replicating your C-j / C-k / C-l navigation
				fzf = {
					["ctrl-k"] = "up",
					["ctrl-j"] = "down",
					["ctrl-l"] = "accept",
				},
			},
		})

		-- Your exact keymaps ported to fzf-lua
		local map = vim.keymap.set
		map("n", "<leader>sh", fzf.help_tags, { desc = "[S]earch [H]elp" })
		map("n", "<leader>sk", fzf.keymaps, { desc = "[S]earch [K]eymaps" })
		map("n", "<leader>sf", fzf.files, { desc = "[S]earch [F]iles" })
		map("n", "<leader>ss", fzf.builtin, { desc = "[S]earch [S]elect fzf-lua" })
		map("n", "<leader>sw", fzf.grep_cword, { desc = "[S]earch current [W]ord" })
		map("n", "<leader>sg", fzf.live_grep, { desc = "[S]earch by [G]rep" })
		map("n", "<leader>sd", fzf.diagnostics_workspace, { desc = "[S]earch [D]iagnostics" })
		map("n", "<leader>sr", fzf.resume, { desc = "[S]earch [R]esume" })
		map("n", "<leader>s.", fzf.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
		map("n", "<leader><leader>", fzf.buffers, { desc = "[ ] Find existing buffers" })

		-- Your "dropdown" buffer search equivalent
		map("n", "<leader>/", function()
			fzf.lgrep_curbuf({
				winopts = {
					height = 0.3,
					width = 0.5,
					relative = "editor",
					row = 0.3,
					preview = { hidden = "hidden" },
				},
			})
		end, { desc = "[/] Fuzzily search in current buffer" })

		-- Search in open files
		map("n", "<leader>s/", function()
			fzf.live_grep({
				grep_open_files = true,
				prompt = "Grep Open Files> ",
			})
		end, { desc = "[S]earch [/] in Open Files" })
	end,
}
