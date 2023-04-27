{ luaHelper, ... }:

# Test all modules that have no config

{
  no-config-tests = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.plugins = {
          git-messenger-vim.enable = true;
          bufdelete.enable = true;
          plantuml-syntax.enable = true;
        };

        nmt.script = ''
          nvimFolder="home-files/.config/nvim"
          config=$(grep "/nix/store.*\.vim" -o $(_abs $nvimFolder/init.lua))

          assertDiff "$config" ${
            pkgs.writeText "no-config-plugins.expected" ''
              ${luaHelper.config.start}

              ${luaHelper.config.end}
            ''
          }
        '';
      };
    };
}
