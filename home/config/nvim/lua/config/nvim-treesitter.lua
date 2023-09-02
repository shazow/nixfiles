require("nvim-treesitter.configs").setup({
    highlight = { enable = true, disable = { "lua" } },
    indent = { enable = true },
    refactor = { highlight_definitions = { enable = true } },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = false,
        node_decremental = "<bs>",
      },
    },
    matchup = { enable = true },
    textsubjects = {
        enable = true,
        prev_selection = ",",
        keymaps = {
            ["."] = "textsubjects-smart",
            [';'] = 'textsubjects-container-outer',
            ['i;'] = 'textsubjects-container-inner',
        },
    },
})
