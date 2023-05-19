{ pkgs, lib, config, ... }:

with lib;

let

  name = "scrollbar";
  pluginUrl = "https://github.com/petertriho/nvim-scrollbar";

  helpers = import ../../helper { inherit pkgs lib config; };

  moduleOptions = with helpers; {
    # add module options here
    #
    # autoStart = boolOption true "Enable this pugin at start"
  };

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    nvim-scrollbar
  ];
}
