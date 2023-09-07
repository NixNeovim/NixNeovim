{ pkgs, lib, helpers, ... }:

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "stabilize";
  pluginUrl = "https://github.com/luukvbaal/stabilize.nvim";

  inherit (helpers.custom_options) boolOption;

  moduleOptions = {
    force = boolOption true "stabilize window even when current cursor position will be hidden behind new window";
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [ stabilize-nvim ];
}
