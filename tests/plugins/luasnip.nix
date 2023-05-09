{ testHelper, ... }:

{
  luasnip-test = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.plugins = {
          luasnip = {
            enable = true;
            path = "./test-path";
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
              -- config for plugin: luasnip
              do
                function setup()
                  -- test lua pre comment
                  require('luasnip.loaders.from_snipmate').lazy_load({ paths = "./test-path" })
                  require('luasnip.loaders.from_lua').lazy_load({ paths = "./test-path" })
                  -- test lua post comment
                end
                success, output = pcall(setup) -- execute 'setup()' and catch any errors
                if not success then
                  print("Error on setup for plugin: luasnip")
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
