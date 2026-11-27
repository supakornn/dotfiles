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

-- At a Neovim split edge, hand off to the tmux navigator when available.
for key, direction in pairs({ h = "Left", j = "Down", k = "Up", l = "Right" }) do
  vim.keymap.set("n", "<C-" .. key .. ">", function()
    local previous = vim.api.nvim_get_current_win()
    vim.cmd("wincmd " .. key)
    if vim.api.nvim_get_current_win() == previous and vim.env.TMUX and vim.env.TMUX ~= "" then
      pcall(vim.cmd, "TmuxNavigate" .. direction)
    end
  end, { silent = true, desc = "Navigate " .. direction .. " (Neovim/tmux)" })
end
