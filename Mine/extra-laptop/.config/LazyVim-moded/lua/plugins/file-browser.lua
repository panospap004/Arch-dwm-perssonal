return {
  "nvim-telescope/telescope-file-browser.nvim",
  dependencies = { "folke/todo-comments.nvim" },
  keys = {
    {
      "<leader>t",
      ":Telescope file_browser path=%:p:h=%:p:h<cr>",
      desc = "Browse Files",
    },
  },
  config = function()
    require("telescope").load_extension("file_browser")
  end,
}
