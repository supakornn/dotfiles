-- Extras: https://www.lazyvim.org/extras
-- Plain LSP is sufficient for Rust/C# browsing; no debugger or test adapters.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      codelens = { enabled = false },
      servers = {
        -- Official JetBrains server supports current Kotlin and Gradle project imports.
        kotlin_language_server = { enabled = false },
        kotlin_lsp = {},
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              checkOnSave = false, -- don't launch cargo check on every small edit
              cargo = { allFeatures = false },
            },
          },
        },
        omnisharp = {
          -- OmniSharp discovers projects from its process cwd, not just rootUri.
          -- Neovim's cmd callback receives the resolved per-project config.
          cmd = function(dispatchers, config)
            return vim.lsp.rpc.start({
              vim.fn.executable("OmniSharp") == 1 and "OmniSharp" or "omnisharp",
              "--languageserver",
              "--hostPID",
              tostring(vim.fn.getpid()),
              "DotNet:enablePackageRestore=false",
            }, dispatchers, { cwd = config.root_dir, env = config.cmd_env })
          end,
          settings = {
            RoslynExtensionsOptions = {
              EnableAnalyzersSupport = false,
              EnableDecompilationSupport = true,
            },
          },
          keys = {
            {
              "gd",
              function()
                require("omnisharp_extended").lsp_definitions()
              end,
              desc = "Goto Definition",
            },
          },
        },
        -- NASM/GAS/Go assembly. Architecture/dialect can be set in .asm-lsp.toml.
        asm_lsp = {},
        cssls = {},
        html = {},
        jsonls = {},
        yamlls = {},
      },
    },
  },
  {
    "Hoffs/omnisharp-extended-lsp.nvim",
    lazy = true,
  },
  {
    "mfussenegger/nvim-jdtls",
    opts = {
      dap = false,
      dap_main = false,
      test = false,
      -- Identical project folder names must not share JDTLS workspaces.
      project_name = function(root)
        return root and (vim.fs.basename(root) .. "-" .. vim.fn.sha256(root):sub(1, 12))
      end,
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "rust", "c_sharp", "asm", "groovy" },
    },
  },
  -- Keep only the base manual formatter. LSPs have their own installer below.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = { "stylua" }
    end,
  },
  -- Diagnostics come from LSPs, not additional background lint processes.
  { "mfussenegger/nvim-lint", enabled = false },
}
