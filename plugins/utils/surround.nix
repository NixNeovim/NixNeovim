{ lib, pkgs, helpers, ... }@attrs:
let
  inherit (helpers.deprecated)
      mkPlugin;
in mkPlugin attrs {
  name = "surround";
  description = "Enable surround.vim";
  extraPlugins = [ pkgs.vimPlugins.surround ];

  options = { };
}
