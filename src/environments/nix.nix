{ lib, pkgs, helpers, config }:
let
  inherit (helpers.deprecated)
      mkPlugin;
in mkPlugin { inherit lib config; } {
  name = "nix";
  description = "Enable nix";
  extraPlugins = [ pkgs.vimPlugins.vim-nix ];

  # Possibly add option to disable Treesitter highlighting if this is installed
  options = { };
}
