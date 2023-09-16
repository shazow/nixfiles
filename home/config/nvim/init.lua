-- base settings
require("config.settings")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

--require("lazy").setup("plugins")
-- FIXME: All the TS plugins get injected in the packpaths, we need to find another way to bundle them maybe
require("lazy").setup("plugins", {
   performance = {
     reset_packpath = false,
   },
 })
