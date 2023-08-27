{ pkgs, lib, helpers, ... }:

with lib;

let

  name = "plantuml-syntax";
  pluginUrl = "https://github.com/aklt/plantuml-syntax";

in helpers.generator.mkLuaPlugin {
  inherit name pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    plantuml-syntax
  ];
  defaultRequire = false;
}
