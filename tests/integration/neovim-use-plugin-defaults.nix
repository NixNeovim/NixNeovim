{ testHelper, pkgs }:
{
  # testing the usePluginDefaults options actually only prints the changes configs
      config = {

        programs.nixneovim = {
          enable = true;
          usePluginDefaults = true;
          plugins.numb = {
            enable = true;
            numberOnly = false;
            showCursorline = false;
          };
          mappings.normal."<leader>h" = { silent = true; action = "'<c-w>H'"; };
        };

        nmt.script = testHelper.moduleTest ''

          assertDiff $normalizedConfig ${
            pkgs.writeText "init.lua-expected" ''

--------------------------------------------------
--                 Globals                      --
--------------------------------------------------

--------------------------------------------------
--                 Options                      --
--------------------------------------------------

--------------------------------------------------
--                 Keymappings                  --
--------------------------------------------------

do vim.keymap.set("n", "<leader>h", '<c-w>H', { ["silent"] = true }) end

--------------------------------------------------
--                 Augroups                     --
--------------------------------------------------

--------------------------------------------------
--               Extra Config (Lua)             --
--------------------------------------------------

-- config for plugin: numb
do
  function setup()

    require('numb').setup {
      ["number_only"] = false,
      ["show_cursorline"] = false
    }

  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: numb")
    print(output)
  end
end
            ''
          }
        '';
      };
}
