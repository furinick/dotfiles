return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = {
      enabled = true,
    },
    servers = {
      qmlls = {
        cmd = { "qmlls6" },
      },
    },
  },
}
