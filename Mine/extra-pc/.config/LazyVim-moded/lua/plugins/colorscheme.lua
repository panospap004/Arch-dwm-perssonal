return {
  -- add gruvbox
  {
    "ellisonleao/gruvbox.nvim",
    "neanias/everforest-nvim",
    "EdenEast/nightfox.nvim",
    "olivercederborg/poimandres.nvim",
  },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nightfox",
      "everforest",
      "gruvbox",
      "poimandres",
    },
  },
}
