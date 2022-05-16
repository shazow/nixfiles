-- Plugins and related configs

---- References:
-- https://github.com/wbthomason/dotfiles/blob/linux/neovim/.config/nvim/lua/plugins.lua
-- https://github.com/noib3/dotfiles/tree/master/defaults/neovim
-- https://github.com/wbthomason/packer.nvim/issues/237
-- https://github.com/nanotee/nvim-lua-guide

local packer = require("packer")

-- Compile on save
vim.cmd([[autocmd BufWritePost plugins.lua PackerCompile]])

packer.init({
	-- Put the generated packer file a bit out of the way
	-- FIXME: This fails to load, need to update the load path too
	--compile_path = require('packer.util').join_paths(vim.fn.stdpath('config'), 'packer', 'packer_compiled.vim')
})

packer.startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	-- Treesitter is managed by the package config, we just manage configs/deps here
	use({ "nvim-treesitter/nvim-treesitter-refactor" })
	use({ "RRethy/nvim-treesitter-textsubjects" })
	require("nvim-treesitter.configs").setup({
		-- highlight = { enable = true, disable = {} }, -- This seems to bork on lua lately (and other languages?)
		indent = { enable = true },
		refactor = { highlight_definitions = { enable = true } },
		incremental_selection = { enable = true },
		matchup = { enable = true },
		textsubjects = {
			enable = true,
			prev_selection = ",",
			keymaps = {
				["."] = "textsubjects-smart",
			},
		},
	})

	use({
		"neovim/nvim-lspconfig", -- Integrate with LSP
		config = function()
			require("config/nvim-lspconfig")
		end,
	})

	use({
		"ray-x/lsp_signature.nvim", -- Replaces lspsaga
		config = function()
			require("lsp_signature").setup()
		end,
	})

	use({
		"folke/trouble.nvim", -- LSP code diagnostics
		config = function()
			require("trouble").setup({})
		end,
	})

	-- use RishabhRD/nvim-lsputils -- Improved LSP ux?

	-- Search
	use({
		"nvim-telescope/telescope.nvim",
		requires = { { "nvim-lua/popup.nvim" }, { "nvim-lua/plenary.nvim" } },
		config = function()
			local map = vim.api.nvim_set_keymap
			map("n", "<c-p>", [[<cmd>Telescope git_files<cr>]], { silent = true })
			map("n", "<c-d>", [[<cmd>Telescope find_files<cr>]], { silent = true })
			map("n", "<c-s>", [[<cmd>Telescope live_grep<cr>]], { silent = true })
			--map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')
			--map('n', 'gd', '<cmd>lua require("telescope.builtin").lsp_definitions()<cr>')
			--map('n', 'gi', '<cmd>lua require("telescope.builtin").lsp_implementations()<cr>')
			--map('n', 'gt', '<cmd>lua require("telescope.builtin").lsp_type_definitions()<cr>')
			map(
				"n",
				"<c-a>",
				[[<cmd>Telescope buffers show_all_buffers=true sort_lastused=true<cr>]],
				{ silent = true }
			)
			map(
				"n",
				"<c-s>",
				[[<cmd>lua require('telescope.builtin').live_grep({ cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1]})<cr>]],
				{ silent = true }
			)
		end,
	})
	use("nvim-telescope/telescope-fzf-native.nvim")

	-- Undo
	use({
		"mbbill/undotree",
		cmd = "UndotreeToggle",
		config = [[vim.g.undotree_SetFocusWhenToggle = 1]],
	})

	-- Zen mode
	use({
		"Pocco81/TrueZen.nvim",
		requires = { "junegunn/limelight.vim" },
		config = function()
			require("true-zen").setup({
				integrations = {
					limelight = true,
					lualine = true,
				},
			})
			vim.cmd([[
				nnoremap <leader>z <cmd>TZAtaraxis<cr>
			]])
		end,
	})

	-- Colorize hex colours
	use({
		"norcalli/nvim-colorizer.lua",
		ft = { "css", "javascript", "vim", "html" },
		config = function()
			require("colorizer").setup({ "css", "javascript", "vim", "html" })
		end,
	})

	-- Neomake
	use({
		"neomake/neomake",
		-- TODO: autocmd! BufWritePost *.py Neomake
	})

	-- GPG: Inline editing of gpg-encrypted files
	use("jamessan/vim-gnupg")

	-- Git
	use({
		"lewis6991/gitsigns.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("gitsigns").setup()
		end,
	})

	use("tpope/vim-sleuth") -- Auto-detect buffer settings

	use("tomtom/tcomment_vim") -- Commenting

	use("famiu/nvim-reload") -- :Reload config

	use({
		"akinsho/toggleterm.nvim", -- Terminal floaties
		config = function()
			require("toggleterm").setup({})
		end,
	})

	-- which-key: Displays a popup with possible keybindings
	--use 'folke/which-key.nvim'

	-- Status line
	--use 'itchyny/lightline.vim'
	use({
		"hoob3rt/lualine.nvim",
		config = function()
			require("lualine").setup({
				options = {
					theme = "tokyonight",
				},
			})
		end,
	})

	-- TODO: Switch to https://github.com/hrsh7th/nvim-cmp (same author, pure lua)
	use({
		"hrsh7th/nvim-compe", -- Completion
		config = function()
			require("config/nvim-compe")
		end,
	})
	-- TODO: Switch to https://github.com/L3MON4D3/LuaSnip?
	use({
		"hrsh7th/vim-vsnip",
		config = function()
			vim.api.nvim_set_keymap("i", "<C-j>", "<Plug>(vsnip-expand)", { expr = true })
			vim.api.nvim_set_keymap("s", "<C-j>", "<Plug>(vsnip-expand)", { expr = true })
		end,
	})
	use({ "hrsh7th/vim-vsnip-integ", requires = { "hrsh7th/vim-vsnip" } })
	-- FIXME: These aren't working?
	use({ "honza/vim-snippets" }) -- Snippet collection
	--use { 'rafamadriz/friendly-snippets' } -- Snippets collection

	--[[ Alternative: Snippets
	use { 'norcalli/snippets.nvim',
		config = function()
			require('snippets').use_suggested_mappings()
			require('snippets').snippets = {
				 date = "${=os.date('%Y-%m-%d')}",
				 datetime = "${=os.date('%Y-%m-%d %r')}",
			}
		end
	}
	use { 'nvim-telescope/telescope-snippets.nvim',
		requires = {'norcalli/snippets.nvim', 'nvim-telescope/telescope.nvim'},
		config = function()
			require('telescope').load_extension('snippets')
		end
	}
	use { 'honza/vim-snippets' } -- Snippet collection
	]]
	--

	use({
		"kyazdani42/nvim-web-devicons", -- Nerdfonts icon override
		config = function()
			require("nvim-web-devicons").setup({ default = true })
		end,
	})

	--[[ It's cool but kinda slow
	use { 'TimUntersberger/neogit', -- Git UI
	  opt = true,
	  cmd = { 'Neogit' },
	  requires = {
	    'nvim-lua/plenary.nvim',
	    'sindrets/diffview.nvim',
	  }
	}
	]]
	--

	use({
		"jose-elias-alvarez/null-ls.nvim", -- Null language-server for formatting etc
		config = function()
			vim.cmd([[
				nnoremap <silent><leader>f <cmd>lua vim.lsp.buf.formatting_sync()<CR>
			]])

			require("null-ls").setup({
				sources = {
					-- require("null-ls").builtins.formatting.stylua, -- Redundant with sumneko
					require("null-ls").builtins.formatting.black,
					-- require("null-ls").builtins.formatting.nixfmt, -- Redundant with rnix?
				},
				on_attach = function(client)
					if client.resolved_capabilities.document_formatting then
						vim.cmd([[
							augroup LspFormatting
							autocmd! * <buffer>
							autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
							augroup END
						]])
					end
				end,
			})
		end,
	})

	use({ "dstein64/vim-startuptime" }) -- startuptime visualizer
	use({
		"rafcamlet/nvim-luapad",
		config = function()
			require("luapad").setup({
				context = {
					the_answer = 42,
				},
			})
		end,
	}) -- Scratchpad, great for calculations, replaces jbyuki/quickmath.nvim

	---- Languages:
	use({ "fatih/vim-go", run = "GoInstallBinaries" }) -- Go
	use({ "LnL7/vim-nix" }) -- Nix
	use({ "posva/vim-vue" }) -- Vue
	use({ "rust-lang/rust.vim" }) -- Rust
	use({ "TovarishFin/vim-solidity" }) -- Solidity

	---- Colorschemes:
	use({
		"sainnhe/sonokai",
		config = function()
			vim.g.sonokai_style = "andromeda"
			--vim.g.sonokai_transparent_background = 1
			--vim.cmd [[hi Statement ctermfg=none guifg=none]]
		end,
	})
	use({ "glepnir/zephyr-nvim" })
	use({ "ishan9299/modus-theme-vim" })
	use({
		"folke/tokyonight.nvim",
		config = function()
			vim.g.tokyonight_style = "night"
			vim.cmd([[colorscheme tokyonight]])
		end,
	})
end)
