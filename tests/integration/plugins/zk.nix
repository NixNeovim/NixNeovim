{ testHelper, pkgs, ... }:

let
  name = "zk";
in {
  zk-test = {

    programs.nixneovim.plugins = {
      "${name}" = {
        enable = true;
        picker = "telescope";
        lsp.autoAttach.filetypes = [ "markdown" "vimwiki" ];
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
        pkgs.writeText "init.lua-expected" ''
          ${testHelper.config.start}
          -- config for plugin: ${name}
          do
            function setup()
              -- test lua pre comment
              require('zk').setup {
                ["lsp"] = {
                  ["auto_attach"] = {
                    ["enabled"] = true,
                    ["filetypes"] = {
                      "markdown",
                      "vimwiki"
                    }
                  },
                  ["config"] = {
                    ["cmd"] = {
                      "zk",
                      "lsp"
                    },
                    ["name"] = "zk"
                  }
                },
                ["picker"] = "telescope"
              }
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
    '';
  };
}
