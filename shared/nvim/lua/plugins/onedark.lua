return {
  -- Onedark colorscheme
  {
    "navarasu/onedark.nvim",
    config = function()
      require("onedark").setup({
        style = "dark",
      })
      require("onedark").load()
    end,
  },

  -- Tell LazyVim to use Onedark as the main colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark",
    },
  },
}
