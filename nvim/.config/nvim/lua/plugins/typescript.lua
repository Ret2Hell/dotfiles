return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Keep the TypeScript extra for debugging/icons, but replace its server.
      -- Clear vtsls-only mappings rather than exposing unsupported commands.
      for _, server in ipairs({ "vtsls", "ts_ls", "tsserver", "tsgo", "tsc" }) do
        opts.servers[server] = { enabled = false }
        opts.setup[server] = nil
      end

      local mise_data = vim.env.MISE_DATA_DIR or ((vim.env.XDG_DATA_HOME or vim.fn.expand("~/.local/share")) .. "/mise")
      opts.servers.tsrs = {
        mason = false,
        -- The shim resolves tsrs without requiring an activated shell PATH.
        cmd = { mise_data .. "/shims/tsrs", "--lsp", "-stdio" },
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
        settings = {
          typescript = {
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
        },
      }
    end,
  },
}
