{ testHelper, ... }:

let
  name = "gruvbox-material";
in {
  "${name}-test" = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.colorschemes = {
          "${name}" = {
            enable = true;
            enableItalic = true;
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

                  vim.g.gruvbox_material_background = "medium"
                  vim.g.gruvbox_material_foreground = "material"
                  vim.g.gruvbox_material_disable_italic_comment = 0
                  vim.g.gruvbox_material_enable_bold = 0
                  vim.g.gruvbox_material_enable_italic = 1
                  vim.g.gruvbox_material_transparent_background = 0
                  vim.g.gruvbox_material_dim_inactive_windows = 0
                  vim.g.gruvbox_material_better_performance = 0

                  vim.cmd[[colorscheme gruvbox-material]]

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
