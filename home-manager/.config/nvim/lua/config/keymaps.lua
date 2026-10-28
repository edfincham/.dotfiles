vim.api.nvim_create_user_command("Qa", "qa", {})

vim.keymap.set("n", "<C-l>", "<C-l><cmd>nohlsearch<cr><cmd>match<cr><cmd>diffupdate<cr>", { silent = true })

vim.keymap.set("n", "<A-Up>", "<C-w>k", { silent = true })
vim.keymap.set("n", "<A-Down>", "<C-w>j", { silent = true })
vim.keymap.set("n", "<A-Left>", "<C-w>h", { silent = true })
vim.keymap.set("n", "<A-Right>", "<C-w>l", { silent = true })
