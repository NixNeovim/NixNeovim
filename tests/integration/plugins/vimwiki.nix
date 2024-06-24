{ testHelper, lib }:

let
  name = "vimwiki";
  nvimTestCommand = ""; # Test command to check if plugin is loaded (optional)
in {
  "${name}-test" = { config, lib, pkgs, ... }:

    {
      config = {

        programs.nixneovim.plugins = {
          "${name}" = {
            enable = true;
            list = [
              {"path" = "~/vimwiki"; "syntax" = "markdown"; "ext" = ".md";}
            ];
            globalExt = 1;
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
                  vim.g.vimwiki_ext2syntax = {
                    [".markdown"] = "markdown",
                    [".md"] = "markdown",
                    [".mdown"] = "markdown",
                    [".mdwn"] = "markdown",
                    [".mkdn"] = "markdown",
                    [".mw"] = "media"
                  }
                  vim.g.vimwiki_global_ext = 1
                  vim.g.vimwiki_list = {
                    {
                      ["ext"] = ".md",
                      ["path"] = "~/vimwiki",
                      ["syntax"] = "markdown"
                    }
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

          check_nvim_start -c "${nvimTestCommand}"
        '';
      };
    };
}
