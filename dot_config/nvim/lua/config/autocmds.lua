-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--vim.api.nvim_create_autocmd({"BufEnter"}, {
--    callback = function(event)
--        local title = "vim"
--        if event.file ~= "" then
--            title = string.format("%s", vim.fs.basename(event.file))
--        end
--
--        vim.fn.system({"wezterm", "cli", "set-tab-title", title})
--    end,
--})

local grp = vim.api.nvim_create_augroup("_formatting", {})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "BufWritePost" }, {
  group = grp,
  pattern = "*",
  callback = function()
    vim.opt_local.fixeol = true
  end,
})
