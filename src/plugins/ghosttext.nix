{ pkgs, lib, helpers, config }:

with lib;

let

  name = "ghosttext";
  pluginUrl = "https://github.com/subnut/nvim-ghost.nvim";

  inherit (helpers.converter)
    flattenModuleOptions
    toLuaObject;

  cfg = config.programs.nixneovim.plugins.${name};
  inherit (helpers.generator)
    mkLuaPlugin;

  moduleOptions = with helpers; { };
  pluginOptions = flattenModuleOptions cfg moduleOptions;

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    nvim-ghost-nvim
  ];
  extraConfigLua = "require('${name}').setup ${toLuaObject pluginOptions}";
  defaultRequire = false;
}
