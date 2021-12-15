require("settings")

-- TODO: Port more configs, e.g:
-- https://github.com/wbthomason/dotfiles/blob/linux/neovim/.config/nvim/init.lua
-- https://oroques.dev/notes/neovim-init/

-- Install Packer automatically:
local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	fn.system({ "git", "clone", "https://github.com/wbthomason/packer.nvim", install_path })
	execute("packadd packer.nvim")
end

require("plugins")
