{ pkgs, lib, helpers, ... }@attrs:

let
  inherit (helpers.deprecated)
    mkPlugin;
in mkPlugin attrs {
  name = "focus";
  description = "Enable focus.nvim";
  extraPlugins = with pkgs.vimExtraPlugins; [
    focus-nvim
  ];
  extraConfigLua = "require('focus').setup {}";
  defaultRequire = false;
}
