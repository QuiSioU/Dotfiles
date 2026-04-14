-- nvim/lua/plugins/init.lua


return {
  --- LSP ------------------------------------------------------------------
  { "neovim/nvim-lspconfig", lazy = false },

  --- Completion -----------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            else fallback() end
          end, { "i", "s" }),
          ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() and cmp.get_selected_entry() then
              cmp.confirm({ select = false })
            else fallback() end
          end),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
        }),
        sources = cmp.config.sources(
          { { name = "nvim_lsp" }, { name = "luasnip" } },
          { { name = "buffer" },   { name = "path" } }
        ),
      })
    end,
  },

  --- Statusline (replaces vim-airline) ------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = {
          theme                = "auto",
          globalstatus         = true,
          icons_enabled        = true,
          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  --- Comments (replaces vim-commentary) -----------------------------------
  {
    "numToStr/Comment.nvim",
    keys = { { "<leader>c", mode = { "n", "x" } } },
    config = function()
      require("Comment").setup({})
      local api = require("Comment.api")
      vim.keymap.set("n", "<leader>c", api.toggle.linewise.current,
        { desc = "Toggle comment" })
      vim.keymap.set("x", "<leader>c", function()
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
        api.toggle.linewise(vim.fn.visualmode())
      end, { desc = "Toggle comment (visual)" })
    end,
  },

  --- Auto pairs (replaces manual inoremap pairs) --------------------------
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({ check_ts = false })
    end,
  },

  --- File explorer (replaces netrw) ---------------------------------------
  {
    "stevearc/oil.nvim",
    lazy = false,
    config = function()
      require("oil").setup({
        view_options        = { show_hidden = false },
        use_default_keymaps = false,
        keymaps = {
          ["h"]     = "actions.parent",
          ["l"]     = "actions.select",
          ["<Esc>"] = "actions.close",
        },
      })
      vim.keymap.set({ "n", "v" }, "<leader>e", function()
        require("oil").toggle_float(vim.fn.expand("%:p:h"))
      end, { desc = "Toggle file explorer" })
    end,
  },
}
