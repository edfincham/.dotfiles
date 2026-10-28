vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

local servers = {
  bashls = { cmd = { "bash-language-server", "start" }, filetypes = { "sh", "bash", "zsh" } },
  buf_ls = { cmd = { "buf", "lsp", "serve" }, filetypes = { "proto" }, root_markers = { "buf.yaml", ".git" } },
  cue = { cmd = { "cue", "lsp" }, filetypes = { "cue" }, root_markers = { "cue.mod", ".git" } },
  dockerls = { cmd = { "docker-langserver", "--stdio" }, filetypes = { "dockerfile" } },
  docker_compose_language_server = {
    cmd = { "docker-compose-langserver", "--stdio" },
    filetypes = { "yaml.docker-compose" },
  },
  gopls = {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gosum", "gotmpl" },
    root_markers = { "go.work", "go.mod", ".git" },
  },
  helm_ls = { cmd = { "helm_ls", "serve" }, filetypes = { "helm" }, root_markers = { "Chart.yaml" } },
  jsonls = { cmd = { "vscode-json-languageserver", "--stdio" }, filetypes = { "json", "jsonc" } },
  lua_ls = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    settings = { Lua = { diagnostics = { globals = { "vim" } } } },
  },
  nixd = { cmd = { "nixd" }, filetypes = { "nix" }, root_markers = { "flake.nix", ".git" } },
  ruff = { cmd = { "ruff", "server" }, filetypes = { "python" } },
  superhtml = { cmd = { "superhtml", "lsp" }, filetypes = { "html" } },
  templ = { cmd = { "templ", "lsp" }, filetypes = { "templ" }, root_markers = { "go.mod", "go.work", ".git" } },
  tflint = {
    cmd = { "tflint", "--langserver" },
    filetypes = { "tf", "terraform", "terraform-vars" },
    root_markers = { ".terraform", ".git" },
  },
  tofu_ls = {
    cmd = { "tofu-ls", "serve" },
    filetypes = { "tf", "opentofu", "opentofu-vars", "terraform", "terraform-vars" },
    root_markers = { ".terraform", ".git" },
  },
  tsgo = {
    cmd = { "tsc", "--lsp", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    root_markers = { "tsconfig.json", "package.json", "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lock" },
  },
  ty = { cmd = { "ty", "server" }, filetypes = { "python" } },
  yamlls = { cmd = { "yaml-language-server", "--stdio" }, filetypes = { "yaml", "yaml.docker-compose" } },
}

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end
