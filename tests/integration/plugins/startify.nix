{ testHelper, lib }:

let
  name = "startify";
  nvimTestCommand = ""; # Test command to check if plugin is loaded (optional)
in {
  "${name}-test" = { config, lib, pkgs, ... }:

    {
      config = {

        programs.nixneovim.plugins = {
          "${name}" = {
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
          assertDiff "$normalizedConfig" ${
            pkgs.writeText "init.lua-expected" /* lua */ ''
              ${testHelper.config.start}
              -- config for plugin: ${name}
              do
                function setup()
                  -- test lua pre comment
                  vim.g.startify_bookmarks = {}
                  vim.g.startify_change_cmd = "lcd"
                  vim.g.startify_change_to_dir = 1
                  vim.g.startify_change_to_vcs_root = 0
                  vim.g.startify_customheader = "'startify#pad(startify#fortune#cowsay())'"
                  vim.g.startify_enable_special = 1
                  vim.g.startify_lists = {}
                  vim.g.startify_skiplist = {}
                  vim.g.startify_update_oldfiles = 0
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

          check_nvim_start -c "${nvimTestCommand}"
        '';
      };
    };
}
