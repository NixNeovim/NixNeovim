{ lib, pkgs, helpers, config }:
let
  inherit (helpers.deprecated)
      mkPlugin;
in mkPlugin { inherit config lib; } {
  name = "surround";
  description = "Enable surround.vim";
  extraPlugins = [ pkgs.vimPlugins.surround ];

  options = { };
}
