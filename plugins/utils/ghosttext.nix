{ pkgs, lib, config, ... }:

with lib;

let

  name = "ghosttext";
  pluginUrl = "https://github.com/subnut/nvim-ghost.nvim";

  helpers = import ../helpers.nix { inherit lib config; };
  cfg = config.programs.nixvim.plugins.${name};

  moduleOptions = with helpers; { };
  pluginOptions = helpers.toLuaOptions cfg moduleOptions;

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    nvim-ghost-nvim
  ];
  extraConfigLua = "require('${name}').setup ${toLuaObject pluginOptions}";
}
