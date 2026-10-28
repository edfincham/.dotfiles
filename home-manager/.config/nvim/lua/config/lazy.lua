local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local output = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", "https://github.com/folke/lazy.nvim.git", lazypath })
  if vim.v.shell_error ~= 0 then
    error("Could not install lazy.nvim: " .. output)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "HoNamDuong/hybrid.nvim", lazy = false, priority = 1000, opts = { transparent = true } },
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>sg", "<cmd>FzfLua live_grep<cr>", desc = "Search project" },
    },
    opts = {},
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    keys = { { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "File tree" } },
    opts = {
      window = { position = "left", width = 25 },
      filesystem = { follow_current_file = { enabled = true } },
    },
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    opts = { keymap = { preset = "default" } },
  },
  { "mrcjkb/rustaceanvim", version = "^9", ft = "rust" },
  {
    "nvim-lualine/lualine.nvim",
    event = "BufEnter",
    opts = {
      options = { component_separators = "", section_separators = "", globalstatus = true },
      sections = {
        lualine_a = {}, lualine_b = {}, lualine_c = { "filename" },
        lualine_x = { "diagnostics" }, lualine_y = {}, lualine_z = {},
      },
    },
  },
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { options = { diagnostics = "nvim_lsp", always_show_bufferline = true } },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<C-w>d", desc = "Show diagnostic under cursor" },
        { "<C-]>", desc = "Go to definition or tag" },
        { "<C-t>", desc = "Jump back from definition" },
      },
    },
    keys = {
      {
        "<leader>?",
        function() require("which-key").show() end,
        desc = "Explore key bindings",
      },
    },
  },
})

vim.cmd.colorscheme("hybrid")
