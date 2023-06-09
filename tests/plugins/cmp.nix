{ testHelper, ... }:

{
  cmp-test = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.plugins = {
          nvim-cmp = {
            enable = true;
            snippet = {
              luasnip.enable = true;
            };
            sources = {
              nvim_lsp = {
                enable = true;
                priority = 10;
              };
              path = {
                enable = true;
                priority = 9;
              };
              luasnip.enable = true;
            };
            mapping = {
              "<C-n>" = "cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert })";
              "<C-p>" = "cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert })";
              "<C-d>" = "cmp.mapping.scroll_docs(-4)";
              "<C-f>" = "cmp.mapping.scroll_docs(4)";
              "<Tab>" = ''
                cmp.mapping.confirm({
                  behavior = cmp.ConfirmBehavior.Replace,
                  select = false,
                })'';
            };
            # extraLua.pre = ''
            #   -- test lua pre comment
            # '';
            # extraLua.post = ''
            #   -- test lua post comment
            # '';
          };
        };

        nmt.script = testHelper.moduleTest ''
          assertDiff "$normalizedConfig" ${
            pkgs.writeText "init.lua-expected" ''
              ${testHelper.config.start}
              -- config for plugin: nvim-cmp
              do
                function setup()
                  local cmp = require('cmp') -- this is needed
                  cmp.setup({
                    ["enabled"] = true,
                    ["mapping"] = {
                      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                      ["<C-f>"] = cmp.mapping.scroll_docs(4),
                      ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                      ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                      ["<Tab>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = false,
              })
              },
                    ["snippet"] = { ["expand"] = function(args) require("luasnip").lsp_expand(args.body) end },
                    ["sources"] = {
                      { ["name"] = "luasnip" },
                      {
                        ["name"] = "nvim_lsp",
                        ["priority"] = 10
                      },
                      {
                        ["name"] = "path",
                        ["priority"] = 9
                      }
                    }
                  })
                  -- extra config of sources
                end
                success, output = pcall(setup) -- execute 'setup()' and catch any errors
                if not success then
                  print("Error on setup for plugin: nvim-cmp")
                  print(output)
                end
              end
              ${testHelper.config.end}
            ''
          }
        '';
      };
    };
}
