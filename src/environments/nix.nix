{ lib, pkgs, helpers, config }:
let

  inherit (helpers.generator)
    mkLuaPlugin;

in mkLuaPlugin {
  name = "nix";
  description = "Enable a set of nix related plugins (this module is in an alpha state)";
  extraPlugins = [
    pkgs.vimPlugins.vim-nix
  ];

}
