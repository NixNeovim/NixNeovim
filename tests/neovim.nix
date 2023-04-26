{
  config = { config, lib, pkgs, ... }:
    {
      config = {
        programs.nixneovim = {
          enable = true;

          plugins.numb.enable = true;
          extraLuaConfig = ''
            -- extraLuaConfig
          '';
        };
        # programs.neovim = {
        #   enable = true;
        #   extraLuaConfig = ''
        #     -- extraLuaConfig
        #   '';
        # };
        nmt.script = ''
          nvimFolder="home-files/.config/nvim"
          assertFileContent "$nvimFolder/init.lua" ${
            pkgs.writeText "init.lua-expected" ''
              -- extraLuaConfig
            ''
          }
        '';
      };
    };
}
