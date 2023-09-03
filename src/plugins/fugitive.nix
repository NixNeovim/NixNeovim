{ pkgs, helpers, config, lib }:
let
  inherit (helpers.deprecated)
      mkPlugin;
in mkPlugin { inherit lib config; } {
  name = "fugitive";
  description = "Enable vim-fugitive";
  extraPlugins = [ pkgs.vimPlugins.vim-fugitive ];

  # In typical tpope fashin, this plugin has no config options
  options = { };
}
