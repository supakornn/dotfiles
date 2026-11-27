-- Loaded after LazyVim defaults. Keep only a few familiar shortcuts.
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Save buffer" })
vim.keymap.set("n", "<leader>'", "<C-^>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>sf", function()
  Snacks.picker.files()
end, { desc = "Find files" })
vim.keymap.set("n", "<leader>so", function()
  Snacks.picker.lsp_symbols()
end, { desc = "Document symbols" })
for _, key in ipairs({ "<C-u>", "<C-d>", "n", "N", "gg", "G" }) do
  vim.keymap.set("n", key, key .. "zz")
end

for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  vim.keymap.set("n", "<C-" .. key .. ">", "<C-w>" .. key, { desc = "Go to " .. direction .. " split" })
end
