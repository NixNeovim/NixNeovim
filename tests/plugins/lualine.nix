{ testHelper, ... }:

{
  lualine-test = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.plugins = {
          lualine = {
            enable = true;
            disabledFiletypes = [ "NvimTree" "tagbar" ];
            sections = {
            lualine_a = [ "mode" ];
            lualine_b = [ "branch" ];
            lualine_c = [ "filename" "diagnostics" ];
            lualine_x = [ "filetype" ];
            lualine_y = [ "diff" ];
            lualine_z = [ "progress" "location" ];
          };

          };
        };

        nmt.script = testHelper.moduleTest ''
          assertDiff "$config" ${
            pkgs.writeText "init.lua-expected" ''
              ${testHelper.config.start}
              require("lualine").setup({
                ["options"] = {
                  ["disabled_filetypes"] = {
                    "NvimTree",
                    "tagbar"
                  },
                  ["globalstatus"] = false
                },
                ["sections"] = {
                  ["lualine_a"] = {
                    "mode"
                  },
                  ["lualine_b"] = {
                    "branch"
                  },
                  ["lualine_c"] = {
                    "filename",
                    "diagnostics"
                  },
                  ["lualine_x"] = {
                    "filetype"
                  },
                  ["lualine_y"] = {
                    "diff"
                  },
                  ["lualine_z"] = {
                    "progress",
                    "location"
                  }
                }
              })
              ${testHelper.config.end}
            ''
          }
        '';
      };
    };
}
