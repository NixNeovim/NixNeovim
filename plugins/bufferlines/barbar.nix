{ lib, pkgs, config, ... }:

with lib;

let

  name = "barbar";

  helpers = import ../helpers.nix { inherit lib config; };
  cfg = config.plugins.${name};

  moduleOptions = with helpers; {
    animation = boolOption true "Enable animations";
    autoHide = boolOption false "Auto-hide the tab bar when there is only one buffer";
    tabpages = boolOption true "Enable 'current/total' tabpages indicator in top right corner";
    closable = boolOption true "Enable the close button";
    clickable = boolOption true "Enable clickable tabs\n - left-click: go to buffer\n - middle-click: delete buffer";
  };

  pluginOptions = helpers.toLuaOptions cfg moduleOptions;

in with helpers;
mkLuaPlugin {
  inherit name moduleOptions;
  description = "Enable ${name}.nvim";
  extraPlugins = with pkgs.vimExtraPlugins; [
      barbar-nvim
      nvim-web-devicons
  ];
  extraConfigLua = "require('bufferline').setup ${toLuaObject pluginOptions}";
}

# Keybinds concept:
# keys = {
#   previousBuffer = mkBindDef "normal" "Previous buffer" { action = ":BufferPrevious<CR>"; silent = true; } "<A-,>";
#   nextBuffer = mkBindDef "normal" "Next buffer" { action = ":BufferNext<CR>"; silent = true; } "<A-.>";
#   movePrevious = mkBindDef "normal" "Re-order to previous" { action = ":BufferMovePrevious<CR>"; silent = true; } "<A-<>";
#   moveNext = mkBindDef "normal" "Re-order to next" { action = ":BufferMoveNext<CR>"; silent = true; } "<A->>";

#   # TODO all the other ones.....
# };
