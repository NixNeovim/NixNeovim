{ testHelper, ... }:

{
  which-key-test = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.plugins = {
          which-key = {
            enable = true;
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
            pkgs.writeText "which-key.expected" ''
              ${testHelper.config.start}
              -- config for plugin: which-key
              do
                function setup()
                  -- test lua pre comment
                  local wk = require('which-key')
                  wk.setup {
                    ["disable"] = {
                      ["buftypes"] = {},
                      ["filetypes"] = {
                        "TelescopePrompt"
                      }
                    },
                    ["plugins"] = {
                      ["marks"] = true,
                      ["presets"] = {
                        ["g"] = true,
                        ["motions"] = true,
                        ["nav"] = true,
                        ["operators"] = true,
                        ["textObjects"] = true,
                        ["windows"] = true,
                        ["z"] = true
                      },
                      ["registers"] = true,
                      ["spelling"] = {
                        ["enabled"] = false,
                        ["suggestions"] = 20
                      }
                    },
                    ["popup_mappings"] = {
                      ["scrollDown"] = "<c-d>",
                     ["scrollUp"] = "<c-u>"
                    },
                    ["window"] = {
                      ["border"] = "none",
                      ["position"] = "bottom"
                    }
                  }
                  -- group names
                  -- test lua post comment
                end
                success, output = pcall(setup) -- execute 'setup()' and catch any errors
                if not success then
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
