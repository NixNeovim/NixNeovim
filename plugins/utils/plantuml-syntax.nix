{ pkgs, lib, config, ... }:

with lib;

let

  name = "plantuml-syntax";
  pluginUrl = "https://github.com/aklt/plantuml-syntax";

  helpers = import ../helpers.nix { inherit lib config; };

in
with helpers;
mkLuaPlugin {
  inherit name pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    plantuml-syntax
  ];
  defaultRequire = false;
}
