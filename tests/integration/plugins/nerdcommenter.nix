{ testHelper, lib }:

let
  name = "nerdcommenter";
  nvimTestCommand = ""; # Test command to check if plugin is loaded (optional)
in {
  "${name}-test" = { config, lib, pkgs, ... }:

    {
      config = {

        programs.nixneovim.plugins = {
          "${name}" = {
            enable = true;
            compactSexyComs = 0;
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
                  vim.g.NERDCompactSexyComs = 0
                  vim.g.NERDCreateDefaultMappings = 1
                  vim.g.NERDDefaultAlign = "left"
                  vim.g.NERDSpaceDelims = 1
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
