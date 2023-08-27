{ pkgs, lib, helpers, ... }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "vimtex";
  pluginUrl = "https://github.com/lervag/vimtex";

  inherit (helpers.custom_options) boolOption;

  moduleOptions = {
    # add module options here
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    vimtex
  ];
  defaultRequire = false;
}
