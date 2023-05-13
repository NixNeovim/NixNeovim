{ testHelper, ... }:

let
  name = "treesitter";
in {
  "${name}-test" = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.plugins = {
          "${name}" = {
            enable = true;
            installAllGrammars = true;
            extraLua.pre = ''
              -- test lua pre comment
            '';
            extraLua.post = ''
              -- test lua post comment
            '';
          };
        };

        nmt.script = testHelper.moduleTest ''
          assertDiff "$config" ${
            pkgs.writeText "init.lua-expected" ''
              ${testHelper.config.start}
              -- config for plugin: ${name}
              do
                function setup()
                  -- test lua pre comment
                  require('nvim-treesitter.configs').setup({
                    ["highlight"] = { ["enable"] = true },
                    ["incremental_selection"] = {
                      ["enable"] = false,
                      ["keymaps"] = {
                        ["init_selection"] = "gnn",
                        ["node_decremental"] = "grm",
                        ["node_incremental"] = "grn",
                        ["scope_incremental"] = "grc"
                      }
                     },
                     ["indent"] = { ["enable"] = false }
                  })
                  -- test lua post comment
                end
                success, output = pcall(setup) -- execute 'setup()' and catch any errors
                if not success then
                  print("Error on setup for plugin: ${name}")
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
