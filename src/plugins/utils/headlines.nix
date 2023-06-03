{ pkgs, lib, config, ... }:

with lib;

let

  name = "headlines";
  pluginUrl = "https://github.com/lukas-reineke/headlines.nvim";

  helpers = import ../../helper { inherit pkgs lib config; };

  moduleOptions = with helpers; {
    # add module options here
  };

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    headlines-nvim
  ];
}
