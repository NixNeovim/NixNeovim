{ pkgs, lib, config, ... }:

with lib;

let

  name = "bufdelete";

  helpers = import ../helpers.nix { inherit lib config; };
  cfg = config.programs.nixvim.plugins.${name};

  moduleOptions = with helpers; {
    # add module options here
  };

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions;
  description = "Enable ${name}.nvim";
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    bufdelete-nvim
  ];
  addRequire = false;
}
