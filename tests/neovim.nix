{
  config = { config, lib, pkgs, ... }:
    {
      config = {
        programs.nixneovim = {
          enable = true;

          plugins.numb.enable = true;
        };
        nmt.script = ''
          nvimFolder="home-files/.config/nvim"
          assertFileContains "$nvimFolder/init.lua" "vim.cmd [[source"
          file=$(grep "/nix/store.*\.vim" -o $(_abs $nvimFolder/init.lua))
          cat $file
          assertFileExists $file
          assertFileContains $file "numb"
        '';
      };
    };
}
# assertFileContent "$nvimFolder/init.lua" ${
#   pkgs.writeText "init.lua-expected" ''
#     -- extraLuaConfig
#   ''
# }
