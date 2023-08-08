{ pkgs, lib, config, ... }:

with lib;

let

  name = "ghosttext";
  pluginUrl = "https://github.com/subnut/nvim-ghost.nvim";

  helpers = import ../../helper { inherit pkgs lib config; };
  cfg = config.programs.nixneovim.plugins.${name};

  moduleOptions = with helpers; { };
  pluginOptions = helpers.convertModuleOptions cfg moduleOptions;

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    nvim-ghost-nvim
  ];
  extraConfigLua = "require('${name}').setup ${toLuaObject pluginOptions}";
  defaultRequire = false;
}
