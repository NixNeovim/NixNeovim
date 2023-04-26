{ luaHelper }:

# Test all modules that have no config

{
  config = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.plugins = {
          git-messenger-vim.enable = true;
          bufdelete.enable = true;
          plantuml-syntax.enable = true;
        };

        nmt.script = ''
          nvimFolder="home-files/.config/nvim"
          file=$(grep "/nix/store.*\.vim" -o $(_abs $nvimFolder/init.lua))

          assertDiff "$file" ${
            pkgs.writeText "init.lua-expected" ''
              ${luaHelper.config.start}
              ${luaHelper.config.end}
            ''
          }
        '';
      };
    };
}
