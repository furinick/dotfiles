return {
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("onedark")

      require("onedarkpro").setup({
        styles = {
          strings = "italic",
        },
      })
    end,
  },
}
