{ lib, pkgs, helpers, ... }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "barbar";
  pluginUrl = "https://github.com/romgrk/barbar.nvim";

  inherit (helpers.custom_options) boolOption;

  moduleOptions = {
    animation = boolOption true "Enable animations";
    autoHide = boolOption false "Auto-hide the tab bar when there is only one buffer";
    tabpages = boolOption true "Enable 'current/total' tabpages indicator in top right corner";
    closable = boolOption true "Enable the close button";
    clickable = boolOption true "Enable clickable tabs\n - left-click: go to buffer\n - middle-click: delete buffer";
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    barbar-nvim
    nvim-web-devicons
  ];
  defaultRequire = false;
}

# Keybinds concept:
# keys = {
#   previousBuffer = mkBindDef "normal" "Previous buffer" { action = ":BufferPrevious<CR>"; silent = true; } "<A-,>";
#   nextBuffer = mkBindDef "normal" "Next buffer" { action = ":BufferNext<CR>"; silent = true; } "<A-.>";
#   movePrevious = mkBindDef "normal" "Re-order to previous" { action = ":BufferMovePrevious<CR>"; silent = true; } "<A-<>";
#   moveNext = mkBindDef "normal" "Re-order to next" { action = ":BufferMoveNext<CR>"; silent = true; } "<A->>";

#   # TODO all the other ones.....
# };
