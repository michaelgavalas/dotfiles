return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "typescript", "tsx", "python", "c", "cpp", "rust", "c_sharp",
        "lua", "bash", "markdown", "markdown_inline", "vim", "vimdoc", "query",
      },
      sync_install = false,
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
