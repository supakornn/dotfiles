-- https://www.lazyvim.org/configuration/general
vim.g.autoformat = false
vim.g.lazyvim_picker = "snacks"
vim.g.lazyvim_cmp = "blink.cmp"
vim.g.lazyvim_prettier_needs_config = true

vim.opt.scrolloff = 8
vim.opt.wrap = false
vim.opt.autoread = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

-- Coursier is used by nvim-metals; keep its installation local to Neovim.
local tools = vim.fn.stdpath("data") .. "/tools"
if vim.fn.executable("cs") == 0 and vim.fn.executable(tools .. "/cs") == 1 then
  vim.env.PATH = tools .. ":" .. vim.env.PATH
end

-- The SDK is already installed locally; expose it only to Neovim and its tools.
local dotnet = vim.fn.expand("~/.dotnet")
if vim.fn.executable("dotnet") == 0 and vim.fn.executable(dotnet .. "/dotnet") == 1 then
  vim.env.DOTNET_ROOT = dotnet
  vim.env.PATH = dotnet .. ":" .. vim.env.PATH
end
