{ luaHelper, ... }:

{
  telescope-test = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim = {
          plugins.telescope = {
            enable = true;
            extensions = {
              manix.enable = true;
              mediaFiles.enable = true;
            };
          };
        };

        nmt.script = ''
          nvimFolder="home-files/.config/nvim"
          file=$(grep "/nix/store.*\.vim" -o $(_abs $nvimFolder/init.lua))

          assertDiff "$file" ${
            pkgs.writeText "init.lua-expected" ''
              ${luaHelper.config.start}
              -- config for plugin: telescope
              do
                function setup()
                  local telescope = require('telescope')
                    telescope.setup {
                      extensions = {
                        ["manix"] = {},
                        ["media_files"] = { ["find_cmd"] = "" }
                      },
                      defaults = {}
                    }
                    telescope.load_extension('manix')
                    telescope.load_extension('media_files')
                end
                success, output = pcall(setup) -- execute 'setup()' and catch any errors
                if not success then
                  print(output)
                end
              end
              ${luaHelper.config.end}
            ''
          }
        '';
      };
    };
}
