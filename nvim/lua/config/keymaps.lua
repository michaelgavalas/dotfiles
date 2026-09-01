vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

map("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })

-- Window navigation (<C-h/j/k/l>) is bound by vim-tmux-navigator in
-- lua/plugins/tmux-navigator.lua, so it also crosses into tmux panes.
