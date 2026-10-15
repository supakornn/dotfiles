-- https://www.lazyvim.org/extras/lang/scala
-- https://github.com/scalameta/nvim-metals
return {
  {
    "scalameta/nvim-metals",
    -- Keep Java on JDTLS; don't attach two JVM language servers to Java buffers.
    ft = { "scala", "sbt" },
    keys = {
      {
        "<leader>me",
        function()
          require("metals").commands()
        end,
        desc = "Metals commands",
      },
    },
    opts = function(_, opts)
      opts.capabilities = require("blink.cmp").get_lsp_capabilities()
      opts.on_attach = nil -- no setup_dap(); LazyVim supplies the standard LSP maps
      opts.settings.serverVersion = "1.6.9"
      opts.settings.verboseCompilation = false
      opts.settings.showImplicitArguments = false
      opts.settings.showImplicitConversionsAndClasses = false
      opts.settings.showInferredType = false
      opts.settings.superMethodLensesEnabled = false
      opts.settings.testUserInterface = nil
      if vim.fn.has("mac") == 1 then
        local home = vim.fn.system({ "/usr/libexec/java_home", "-v", "21" })
        if vim.v.shell_error == 0 then
          opts.settings.javaHome = vim.trim(home)
          opts.cmd_env = { JAVA_HOME = opts.settings.javaHome }
        end
      end
    end,
    config = function(plugin, opts)
      local attach = function()
        require("metals").initialize_or_attach(opts)
      end
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("nvim-metals", { clear = true }),
        pattern = plugin.ft,
        callback = attach,
      })
      -- Lazy loading happens during FileType: explicitly attach the first buffer too.
      if vim.tbl_contains(plugin.ft, vim.bo.filetype) then
        attach()
      end
    end,
  },
}
