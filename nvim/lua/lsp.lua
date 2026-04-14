-- nvim/lua/lsp.lua


-- Uses vim.lsp.config (nvim 0.11+) instead of the deprecated lspconfig framework

-- Shared on_attach keymaps
local function on_attach(_, bufnr)
  local bmap = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end
  bmap("n", "gd",         vim.lsp.buf.definition,     "Go to definition")
  bmap("n", "gD",         vim.lsp.buf.declaration,    "Go to declaration")
  bmap("n", "gi",         vim.lsp.buf.implementation, "Go to implementation")
  bmap("n", "gr",         vim.lsp.buf.references,     "References")
  bmap("n", "K",          vim.lsp.buf.hover,          "Hover docs")
  bmap("n", "<leader>rn", vim.lsp.buf.rename,         "Rename symbol")
  bmap("n", "<leader>ca", vim.lsp.buf.code_action,    "Code action")
  bmap("n", "<leader>d",  vim.diagnostic.open_float,  "Show diagnostic")
  bmap("n", "[d",         vim.diagnostic.goto_prev,   "Prev diagnostic")
  bmap("n", "]d",         vim.diagnostic.goto_next,   "Next diagnostic")
end

-- Capabilities (enhanced by nvim-cmp when it loads)
local function get_capabilities()
  local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then return cmp_lsp.default_capabilities() end
  return vim.lsp.protocol.make_client_capabilities()
end

--- C / C++ (clangd) --------------------------------------------------------
vim.lsp.config("clangd", {
  cmd          = { "clangd", "--background-index" },
  filetypes    = { "c", "cpp", "objc", "objcpp" },
  capabilities = get_capabilities(),
  on_attach    = on_attach,
})
vim.lsp.enable("clangd")

--- Python (pyright) --------------------------------------------------------
vim.lsp.config("pyright", {
  cmd          = { "pyright-langserver", "--stdio" },
  filetypes    = { "python" },
  capabilities = get_capabilities(),
  on_attach    = on_attach,
  settings     = {
    python = { pythonPath = "/usr/bin/python3" },
  },
})
vim.lsp.enable("pyright")

-- Inlay hints off
vim.lsp.inlay_hint.enable(false)
