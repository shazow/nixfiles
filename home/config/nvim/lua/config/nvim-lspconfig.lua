local nvim_lsp = require("lspconfig")

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end

	local function buf_set_option(...)
		vim.api.nvim_buf_set_option(bufnr, ...)
	end

	--Enable completion triggered by <c-x><c-o>
	buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

	-- Mappings.
	local opts = { noremap = true, silent = true }

	-- See `:help vim.lsp.*` for documentation on any of the below functions
	buf_set_keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
	buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
	buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	buf_set_keymap("n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
	buf_set_keymap("n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
	buf_set_keymap("n", "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
	buf_set_keymap("n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
	buf_set_keymap("n", "<leader>re", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	buf_set_keymap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
	buf_set_keymap("n", "<leader>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
	buf_set_keymap("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
	buf_set_keymap("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
	buf_set_keymap("n", "<leader>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)
	buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end

require('lazy-lsp').setup {
	default_config = {
		on_attach = on_attach,
	},
	-- Override config for specific servers that will passed down to lspconfig setup.
	configs = {
		sumneko_lua = {
			cmd = {"lua-language-server"},
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" }, -- Ignore missing vim global which is injected
					},
				},
			},
			commands = {
				Format = {
					function()
						vim.lsp.buf.formatting_sync()
					end,
				},
			},
			on_attach = on_attach,
    },
  },
}

-- TODO: Delete the following if w're happy with "dundalek/lazy-lsp.nvim

local function nixcmd(pkg, flag)
	-- Helper for producing the nix run command tuple.
	-- TODO: Could detect if `nix run` exists, otherwise use `nix-shell -p $foo --run`
	-- TODO: Could detect if there is no nix, and default to no-op
	return { cmd = { "nix", "run", "nixpkgs#" .. pkg, "--", flag } }
end
local function addservers(nvim_lsp)
	-- Use a loop to conveniently call 'setup' on multiple servers and
	-- map buffer local keybindings when the language server attaches
	local servers = {}

	servers["gopls"] = nixcmd("gopls")
	servers["jedi_language_server"] = nixcmd("python3Packages.jedi-language-server") -- Python
	servers["rnix"] = nixcmd("rnix-lsp") -- nix
	servers["rust_analyzer"] = nixcmd("rust-analyzer")
	servers["tsserver"] = nixcmd("nodePackages.typescript-language-server", '--stdio') -- TypeScript and JavaScript
	servers["vuels"] = nixcmd("nodePackages.vls")
	servers["zls"] = nixcmd("zls") -- zig

	for name, lsp_cfg in pairs(servers) do
		-- Merge configs, this way config is optional (can pass {})
		local cfg = vim.tbl_deep_extend("keep", lsp_cfg, { on_attach = on_attach })
		nvim_lsp[name].setup(cfg)
	end

	-- Setup lua separately because we inject vim configs
	nvim_lsp.sumneko_lua.setup({
		cmd = { "lua-language-server" },
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" }, -- Ignore missing vim global which is injected
				},
			},
		},
		commands = {
			Format = {
				function()
					vim.lsp.buf.formatting_sync()
				end,
			},
		},
		on_attach = on_attach,
	})
end
