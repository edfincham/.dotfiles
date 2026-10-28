vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.clipboard:append("unnamedplus")

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.foldmethod = "indent"
vim.opt.foldlevelstart = 999

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact", "yaml", "yaml.docker-compose", "css" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

vim.filetype.add({
  extension = { gotmpl = "gotmpl", tmpl = "gotmpl" },
  filename = {
    ["docker-compose.yml"] = "yaml.docker-compose",
    ["docker-compose.yaml"] = "yaml.docker-compose",
    ["compose.yml"] = "yaml.docker-compose",
    ["compose.yaml"] = "yaml.docker-compose",
    ["helmfile.yml"] = "helm",
    ["helmfile.yaml"] = "helm",
  },
  pattern = {
    [".*/templates/.*%.yaml"] = "helm",
    [".*/templates/.*%.yml"] = "helm",
    [".*/templates/.*%.tpl"] = "helm",
  },
})
