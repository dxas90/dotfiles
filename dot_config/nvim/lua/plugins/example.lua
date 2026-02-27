-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore
if true then
  return {
   {"snacks.nvim",
      opts = {
          dashboard = {
              preset = {
                  header = [[
 ██╗     ██╗███████╗███████╗    ██╗███████╗     ██████╗ ██╗   ██╗████████╗███████╗██╗██████╗ ███████╗
 ██║     ██║██╔════╝██╔════╝    ██║██╔════╝    ██╔═══██╗██║   ██║╚══██╔══╝██╔════╝██║██╔══██╗██╔════╝
██║     ██║█████╗  █████╗      ██║███████╗    ██║   ██║██║   ██║   ██║   ███████╗██║██║  ██║█████╗
██║     ██║██╔══╝  ██╔══╝      ██║╚════██║    ██║   ██║██║   ██║   ██║   ╚════██║██║██║  ██║██╔══╝
 ███████╗██║██║     ███████╗    ██║███████║    ╚██████╔╝╚██████╔╝   ██║   ███████║██║██████╔╝███████╗
 ╚══════╝╚═╝╚═╝     ╚══════╝    ╚═╝╚══════╝     ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝╚═╝╚═════╝ ╚══════╝
                                                                                         ▗       ▗
                                                                                      ▛▌█▌▜▘  ▛▌▌▌▜▘
                                                                                      ▙▌▙▖▐▖  ▙▌▙▌▐▖
                                                                         ▄▌
                  ]]
              }
          }
      }},
  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   opts = { ensure_installed = { "terraform", "hcl" } },
  -- },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        terraformls = {},
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "tflint" } },
  },
  {
    "ANGkeith/telescope-terraform-doc.nvim",
    ft = { "terraform", "hcl" },
    config = function()
      LazyVim.on_load("telescope.nvim", function()
        require("telescope").load_extension("terraform_doc")
      end)
    end,
  },
  { "Freed-Wu/code-stats.nvim", lazy = true },
  { "nvim-lua/plenary.nvim", lazy = true },
  {
    "glepnir/template.nvim",
    lazy = true, -- Explicitly mark this plugin for lazy loading
    cmd = { "Template", "TemProject" }, -- Lazy load when these commands are used
    keys = {
      {
        "<leader>ct",
        function() vim.fn.feedkeys(":Template ") end,
        desc = "Open Template",
      },
    },
    opts = {
      temp_dir = "~/.config/nvim/templates", -- Template directory
      author = "Daniel Ramirez",             -- Your name
      email = "dxas90@gmail.com",            -- Email address
    },
    config = function(_, opts)
      require("template").setup(opts)
    end,
  },
 }
end
