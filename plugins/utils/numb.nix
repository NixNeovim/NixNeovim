{ pkgs, lib, config, ... }:

with lib;

let

  name = "numb";
  pluginUrl = "https://github.com/nacro90/numb.nvim";

  helpers = import ../../helper { inherit pkgs lib config; };
  inherit (helpers.customOptions) boolOption;

  moduleOptions = {
    showNumbers = boolOption true "Enable 'number' for the window while peeking";
    showCursorline = boolOption true "Enable 'cursorline' for the window while peeking";
    numberOnly = boolOption false "Peek only when the command is only a number instead of when it starts with a number";
    centeredPeeking = boolOption true "Peeked line will be centered relative to window";
  };

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    numb-nvim
  ];
}
