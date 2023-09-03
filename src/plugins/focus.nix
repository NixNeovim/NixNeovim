{ pkgs, lib, helpers, config }:

let

  inherit (helpers.deprecated)
    mkPlugin;

in mkPlugin { inherit lib config; } {
  name = "focus";
  description = "Enable focus.nvim";
  extraPlugins = with pkgs.vimExtraPlugins; [
    focus-nvim
  ];
  extraConfigLua = "require('focus').setup {}";
  defaultRequire = false;
}
