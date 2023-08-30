{ testHelper, haumea, lib }:

# This module performs a very basic check for all available plugins
# It only confirms that there are no errors on startup, when the respective
# module is enabled. This does not check that the plugins is actually loaded
# or otherwise working as intended
# Because the evaluation of the neovim derivation would take too long when
# activating all plugins at the same time, we split activate them in groups
# The groups are formed by the starting letter of the plugin name.
# This ways only a couple of plugins are activated at the same time.

let

  plugins =
    let
      src = haumea.lib.load {
        src = ../../plugins;
      };
    in with src;
      bufferlines //
      # colorschemes //
      completion //
      { nvim-dap-ui = debugging.nvim-dap-ui; } //
      { nvim-dap = debugging.nvim-dap.default; } //
      git //
      languages //
      { mini = mini.default; } //
      # null-ls //
      { lsp = nvim-lsp.default; } //
      pluginmanagers //
      statuslines //
      { telescope = telescope.default; } //
      utils;
      # { inherit generated; };

  pluginNames = builtins.attrNames plugins;

  moduleTemplate = map
    (name:
      {
        "basic-check-${name}" =
          {
            programs.nixneovim.plugins = { ${name} = { enable = true; }; }; # // pluginsWithErrors;
            nmt.script = testHelper.moduleTest "";
          };

        "basic-check-${name}-use-plugin-default" =
          {
            programs.nixneovim.plugins = { ${name} = { enable = true; }; }; # // pluginsWithErrors;
            programs.nixneovim.usePluginDefaults = true;
            nmt.script = testHelper.moduleTest "";
          };
      }
    )
    pluginNames;

in builtins.foldl' (final: set: final // set) {} moduleTemplate
