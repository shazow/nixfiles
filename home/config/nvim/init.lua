require("settings")

-- TODO: Port more configs, e.g:
-- https://github.com/wbthomason/dotfiles/blob/linux/neovim/.config/nvim/init.lua
-- https://oroques.dev/notes/neovim-init/

-- Install Packer automatically:
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

return require('packer').startup(function(use)
  -- Packer can manage itself
  use("wbthomason/packer.nvim")

  require("plugins")(use)

  local packer_bootstrap = ensure_packer()
  if packer_bootstrap then
    require('packer').sync()
  end
end)
