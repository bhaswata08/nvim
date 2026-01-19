vim.g.tmux_navigator_no_mappings = 1
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
local opts = { noremap = true, silent = true }

-- save file without auto-formatting
vim.keymap.set("n", "<leader>sn", "<cmd>noautocmd w <CR>", opts)

-- delete single character without copying into register
vim.keymap.set("n", "x", '"_x', opts)

-- Vertical scroll and center
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)

-- Find and center
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "Nzzzv", opts)

-- Resize with arrows
vim.keymap.set("n", "<Up>", ":resize -2<CR>", opts)
vim.keymap.set("n", "<Down>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<Left>", ":vertical resize -2<CR>", opts)
vim.keymap.set("n", "<Right>", ":vertical resize +2<CR>", opts)

-- Buffers
vim.keymap.set("n", "<Tab>", ":bnext<CR>", opts)
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", opts)
vim.keymap.set("n", "<leader>bq", ":Bdelete!<CR>", opts) -- close buffer
vim.keymap.set("n", "<leader>bo", "<cmd> enew <CR>", opts) -- new buffer

-- Window Management
vim.keymap.set("n", "<leader>v", "<C-w>v", opts) -- split window vertically
vim.keymap.set("n", "<leader>h", "<C-w>s", opts) -- split window horizontally
vim.keymap.set("n", "<leader>s=", "<C-w>=", opts) -- make splits equal
vim.keymap.set("n", "<leader>sq", ":close<CR>", opts) -- close split

-- Navigate between splits
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Tab management
vim.keymap.set("n", "<leader>to", ":tabnew<CR>", opts) -- open new tab
vim.keymap.set("n", "<leader>tq", ":tabclose<CR>", opts) -- close tab
vim.keymap.set("n", "<leader>tn", ":tabn<CR>", opts) -- go to next tab
vim.keymap.set("n", "<leader>tp", ":tabp<CR>", opts) -- go to previous tab

-- Toggle line wrap
vim.keymap.set("n", "<leader>lw", "<cmd>set wrap!<CR>", opts) -- toggle line wrap

-- Stay in indent mode
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Keep last yanked when pasting
vim.keymap.set("v", "p", '"_dP', opts)

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
