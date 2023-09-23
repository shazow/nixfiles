-- Plugins and related configs

return {
    -- Treesitter is managed by the package config, we just manage configs/deps here
    { "RRethy/nvim-treesitter-textsubjects",
        event = "BufReadPre",
        config = function()
            require('config/nvim-treesitter')
        end
    },

    -- TODO: Investigate treesitter-based semantic search/replace plugins:
    -- https://github.com/cshuaimin/ssr.nvim
    -- https://github.com/vigoux/architext.nvim

    {
        "neovim/nvim-lspconfig", -- Integrate with LSP
    },

    {
        "dundalek/lazy-lsp.nvim",
        event = "BufReadPost",
        config = function()
            require("config/nvim-lspconfig")
        end,
    },

    {
        "ray-x/lsp_signature.nvim", -- Replaces lspsaga
        config = function()
            require("lsp_signature").setup()
        end,
    },

    {
        "simrat39/symbols-outline.nvim",
        keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
        cmd = "SymbolsOutline",
        opts = {},
    },


    {
        "folke/trouble.nvim", -- LSP code diagnostics
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("trouble").setup({})
        end,
    },

    -- use RishabhRD/nvim-lsputils -- Improved LSP ux?

    -- Search
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { { "nvim-lua/popup.nvim" }, { "nvim-lua/plenary.nvim" } },
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
    },

    "nvim-telescope/telescope-fzf-native.nvim",
    "stevearc/dressing.nvim", -- vim.ui.select(...) hooks for enhancing with telescope

    -- Undo
    {
        "mbbill/undotree",
        cmd = "UndotreeToggle",
        config = [[vim.g.undotree_SetFocusWhenToggle = 1]],
    },

    -- Zen mode
    {
        "Pocco81/true-zen.nvim",
        dependencies = { "folke/twilight.nvim" },
        cmd = "TZAtaraxis",
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
    },

    -- Colorize hex colours
    {
        "norcalli/nvim-colorizer.lua",
        ft = { "css", "javascript", "vim", "html" },
        config = function()
            require("colorizer").setup({ "css", "javascript", "vim", "html" })
        end,
    },

    -- Neomake
    {
        "neomake/neomake",
        -- TODO: autocmd! BufWritePost *.py Neomake
    },

    -- GPG: Inline editing of gpg-encrypted files
    "jamessan/vim-gnupg",

    -- Git
    {
        "lewis6991/gitsigns.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("gitsigns").setup()
        end,
    },

    -- Edit filesystem like a buffer
    {
        "stevearc/oil.nvim",
        config = function()
            require("oil").setup()
        end,
    },

    --use("tpope/vim-sleuth") -- Auto-detect buffer settings

    "tomtom/tcomment_vim", -- Commenting

    {
        "akinsho/toggleterm.nvim", -- Terminal floaties
        config = function()
            require("toggleterm").setup({})
        end,
    },

    { 'folke/which-key.nvim' }, -- Displays a popup with possible keybindings
    {
        'mrjones2014/legendary.nvim', -- Search for key bindings
        config = function()
            require("legendary").setup({
                which_key = { auto_register = true }
            })
        end,
    },

    -- Status line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { 'arkav/lualine-lsp-progress' },
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
    },

    { "rcarriga/nvim-notify" },

    -- TODO: Switch to https://github.com/hrsh7th/nvim-cmp (same author, pure lua)
    {
        "hrsh7th/nvim-compe", -- Completion
        config = function()
            require("config/nvim-compe")
        end,
    },
    -- TODO: Switch to https://github.com/L3MON4D3/LuaSnip?
    {
        "hrsh7th/vim-vsnip",
        config = function()
            vim.api.nvim_set_keymap("i", "<C-j>", "<Plug>(vsnip-expand)", { expr = true })
            vim.api.nvim_set_keymap("s", "<C-j>", "<Plug>(vsnip-expand)", { expr = true })
        end,
    },
    { "hrsh7th/vim-vsnip-integ", dependencies = { "hrsh7th/vim-vsnip" } },
    -- FIXME: These aren't working?
    { "honza/vim-snippets" }, -- Snippet collection
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

    {
        "nvim-tree/nvim-web-devicons", -- Nerdfonts icon override
        config = function()
            require("nvim-web-devicons").setup({ default = true })
        end,
    },

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

    {
        "akinsho/git-conflict.nvim",
        version = "*",
        config = function()
            require('git-conflict').setup()
        end
    }, -- Resolve git conflicts

    { "dstein64/vim-startuptime" }, -- startuptime visualizer
    {
        "rafcamlet/nvim-luapad",
        cmd = "Luapad",
        config = function()
            require("luapad").setup({
                context = {
                    the_answer = 42,
                },
            })
        end,
    }, -- Scratchpad, great for calculations, replaces jbyuki/quickmath.nvim

    { "github/copilot.vim" },

    {
        "NMAC427/guess-indent.nvim",
        config = function()
            require('guess-indent').setup({})
        end,
    }, -- Guess indent settings

    ---- Languages:
    { "fatih/vim-go", run = "GoInstallBinaries" }, -- Go
    { "LnL7/vim-nix" },                         -- Nix
    { "posva/vim-vue" },                        -- Vue
    { "rust-lang/rust.vim" },                   -- Rust
    { "TovarishFin/vim-solidity" },             -- Solidity
    { "iden3/vim-circom-syntax" },              -- Circom
    --{ "evanleck/vim-svelte" }, -- Svelte... shouldn't need this but /shrug

    ---- Colorschemes:
    { "zaldih/themery.nvim",
        config = function()
            require("themery").setup({
                themes = {"sonokai", "zephyr", "modus", "tokyonight", "witchhazel"},
            })
        end,
    }, -- Colorscheme Manager

    {
        "sainnhe/sonokai",
        config = function()
            vim.g.sonokai_style = "andromeda"
            --vim.g.sonokai_transparent_background = 1
            --vim.cmd [[hi Statement ctermfg=none guifg=none]]
        end,
    },
    { "glepnir/zephyr-nvim" },
    { "ishan9299/modus-theme-vim" },
    {
        "folke/tokyonight.nvim",
        config = function()
            vim.g.tokyonight_style = "night"
            vim.cmd([[colorscheme tokyonight]])
        end,
    },
    { "theacodes/witchhazel" },
}
