{ testHelper, ... }:

{
  plantuml-syntax-test = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.plugins = {
          plantuml-syntax = {
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
          assertDiff "$config" ${
            pkgs.writeText "init.lua-expected" ''
              ${testHelper.config.start}
              -- config for plugin: plantuml-syntax
              do
                function setup()
                  -- test lua pre comment
                  -- test lua post comment
                end
                success, output = pcall(setup) -- execute 'setup()' and catch any errors
                if not success then
                  print("Error on setup for plugin: plantuml-syntax")
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
