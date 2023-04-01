{ pkgs, lib, config, ... }:

with lib;

let

  name = "PLUGIN_NAME";
  pluginUrl = "PLUGIN_URL";

  helpers = import ../../helper { inherit pkgs lib config; };
  inherit (helpers.customOptions) boolOption;

  moduleOptions = {
    # add module options here
  };

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
  ];
}
