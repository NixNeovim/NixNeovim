{ testHelper, ... }:

# Test all modules that have no config

{
  no-config-tests = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.plugins = {
          git-messenger.enable = true;
          bufdelete.enable = true;
        };

        nmt.script = testHelper.moduleTest ''
          assertDiff "$normalizedConfig" ${
            pkgs.writeText "no-config-plugins.expected" ''
              vim.cmd [[source <nix-store-hash>-nvim-init-home-manager.vim]]
              ${testHelper.config.start}

              ${testHelper.config.end}
            ''
          }
        '';
      };
    };
}
