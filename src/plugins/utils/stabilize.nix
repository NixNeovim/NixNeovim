{ pkgs, lib, config, ... }:

let

  name = "stabilize";
  pluginUrl = "https://github.com/luukvbaal/stabilize.nvim";

  helpers = import ../../helper { inherit pkgs lib config; };
  inherit (helpers.customOptions) boolOption;

  moduleOptions = {
    force = boolOption true "stabilize window even when current cursor position will be hidden behind new window";
  };

in
with lib; with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [ stabilize-nvim ];
}
