{ luaHelper, ... }:

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

        nmt.script = ''
          nvimFolder="home-files/.config/nvim"
          file=$(grep "/nix/store.*\.vim" -o $(_abs $nvimFolder/init.lua))

          assertDiff "$file" ${
            pkgs.writeText "init.lua-expected" ''
              ${luaHelper.config.start}
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
