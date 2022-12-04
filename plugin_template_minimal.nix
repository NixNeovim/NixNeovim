{ pkgs, lib, config, ... }:

with lib;

let

  name = "PLUGIN_NAME";
  plugin-url = "PLUGIN_URL";

  helpers = import ../helpers.nix { inherit lib config; };

  moduleOptions = with helpers; {
    # add module options here
  };

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions;
  description = "Enable ${name}.nvim (${plugin-url})";
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    # nvim-treesitter
  ];
  extraPackages = with pkgs; [
    # add dependencies here
    # tree-sitter
  ];
}
