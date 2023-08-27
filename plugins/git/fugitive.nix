{ pkgs, helpers, ... }@attrs:
let
  inherit (helpers.deprecated)
      mkPlugin;
in mkPlugin attrs {
  name = "fugitive";
  description = "Enable vim-fugitive";
  extraPlugins = [ pkgs.vimPlugins.vim-fugitive ];

  # In typical tpope fashin, this plugin has no config options
  options = { };
}
