-- Plugins and related configs

---- References:
-- https://github.com/wbthomason/dotfiles/blob/linux/neovim/.config/nvim/lua/plugins.lua
-- https://github.com/noib3/dotfiles/tree/master/defaults/neovim
-- https://github.com/wbthomason/packer.nvim/issues/237
-- https://github.com/nanotee/nvim-lua-guide

-- Compile on save
vim.cmd([[autocmd BufWritePost plugins.lua PackerCompile]])

return function(use)
	-- Treesitter is managed by the package config, we just manage configs/deps here
	use({ "nvim-treesitter/nvim-treesitter-refactor" })
	use({ "RRethy/nvim-treesitter-textsubjects" })
	require("nvim-treesitter.configs").setup({
		highlight = { enable = false, disable = { "lua" } },
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

	-- TODO: Investigate treesitter-based semantic search/replace plugins:
	-- https://github.com/cshuaimin/ssr.nvim
	-- https://github.com/vigoux/architext.nvim

	use({
		"neovim/nvim-lspconfig", -- Integrate with LSP
		config = function()
			require("config/nvim-lspconfig")
		end,
	})

	use({
		"dundalek/lazy-lsp.nvim",
	})

	use({
		"ray-x/lsp_signature.nvim", -- Replaces lspsaga
		config = function()
			require("lsp_signature").setup()
		end,
	})

	use({
		"folke/trouble.nvim", -- LSP code diagnostics
		requires = "kyazdani42/nvim-web-devicons",
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
				[[<cmd>lua require('telescope.builtin').live_grep({ cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1]})<cr>]]
				,
				{ silent = true }
			)
		end,
	})
	use("nvim-telescope/telescope-fzf-native.nvim")
	use("stevearc/dressing.nvim") -- vim.ui.select(...) hooks for enhancing with telescope

	-- Undo
	use({
		"mbbill/undotree",
		cmd = "UndotreeToggle",
		config = [[vim.g.undotree_SetFocusWhenToggle = 1]],
	})

	-- Zen mode
	use({
		"Pocco81/true-zen.nvim",
		requires = { "folke/twilight.nvim" },
		config = function()
			require("true-zen").setup({
				integrations = {
					twilight = true,
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

	-- Edit filesystem like a buffer
	use({
		"stevearc/oil.nvim",
		config = function()
			require("oil").setup()
		end,
	})

	--use("tpope/vim-sleuth") -- Auto-detect buffer settings

	use("tomtom/tcomment_vim") -- Commenting

	use({
		"akinsho/toggleterm.nvim", -- Terminal floaties
		config = function()
			require("toggleterm").setup({})
		end,
	})

	use({ 'folke/which-key.nvim' }) -- Displays a popup with possible keybindings
	use({ 'mrjones2014/legendary.nvim', -- Search for key bindings
		config = function()
			require("legendary").setup({
				which_key = { auto_register = true }
			})
		end,
	})

	-- Status line
	use({
		"nvim-lualine/lualine.nvim",
		requires = { 'arkav/lualine-lsp-progress', opt = true },
		config = function()
			require("lualine").setup({
				options = {
					theme = "tokyonight",
				},
				sections = {
					lualine_c = { 'filename', 'lsp_progress' },
				},
			})
		end,
	})

	use({ "rcarriga/nvim-notify" })

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
		"nvim-tree/nvim-web-devicons", -- Nerdfonts icon override
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

	use({ "akinsho/git-conflict.nvim", tag = "*", config = function()
		require('git-conflict').setup()
	end}) -- Resolve git conflicts

	use({
		"jose-elias-alvarez/null-ls.nvim", -- Null language-server for formatting etc
		config = function()
			vim.cmd([[
				nnoremap <silent><leader>f <cmd>lua vim.lsp.buf.formatting_sync()<CR>
			]])

			--require("null-ls").setup({
			--	on_attach = function(client)
			--		if client.resolved_capabilities.document_formatting then
			--			vim.cmd([[
			--				augroup LspFormatting
			--				autocmd! * <buffer>
			--				autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
			--				augroup END
			--			]])
			--		end
			--	end,
			--})
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

	use({ "github/copilot.vim" })

	---- Languages:
	use({ "fatih/vim-go", run = "GoInstallBinaries" }) -- Go
	use({ "LnL7/vim-nix" }) -- Nix
	use({ "posva/vim-vue" }) -- Vue
	use({ "rust-lang/rust.vim" }) -- Rust
	use({ "TovarishFin/vim-solidity" }) -- Solidity
	use({ "iden3/vim-circom-syntax" }) -- Circom

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
end
