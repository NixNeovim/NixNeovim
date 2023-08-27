{ pkgs, lib, helpers, ... }:

with lib;

let

  name = "headlines";
  pluginUrl = "https://github.com/lukas-reineke/headlines.nvim";

  inherit (helpers.generator)
    mkLuaPlugin;

  moduleOptions = with helpers; {
    # add module options here
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    headlines-nvim
  ];
}
