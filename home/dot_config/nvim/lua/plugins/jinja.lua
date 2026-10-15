-- Copier templates: detect the host language and overlay Jinja syntax.
return {
  {
    "HiPhish/jinja.vim",
    lazy = false, -- filetype detection must be available before opening templates
    config = function()
      -- Upstream uses :file to detect the host language. Its unescaped restore
      -- expands '%' in Copier's {% ... %} paths and corrupts the buffer name.
      local patterns = { "*.jinja", "*.jinja2", "*.j2" }
      vim.api.nvim_clear_autocmds({
        group = "filetypedetect",
        event = { "BufRead", "BufNewFile" },
        pattern = patterns,
      })
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        group = vim.api.nvim_create_augroup("jinja_literal_paths", { clear = true }),
        pattern = patterns,
        callback = function(event)
          local filename = event.file:gsub("%.jinja2?$", ""):gsub("%.j2$", "")
          local host = vim.filetype.match({ filename = filename, buf = event.buf })
          vim.bo[event.buf].filetype = host and (host .. ".jinja") or "jinja"
          vim.bo[event.buf].syntax = "on" -- retain the Jinja overlay alongside Tree-sitter
        end,
      })
    end,
  },
}
