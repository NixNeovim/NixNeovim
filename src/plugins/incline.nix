{ pkgs , lib , config , helpers }:
with lib;
let

  inherit (helpers.generator)
     mkLuaPlugin;

  inherit (helpers.converter)
    flattenModuleOptions
    toLuaObject;

  name = "incline";
  pluginUrl = "https://github.com/b0o/incline.nvim";

  cfg = config.programs.nixneovim.plugins.${name};

  moduleOptions = with helpers; {
  };

  pluginOptions = flattenModuleOptions cfg moduleOptions;

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    incline-nvim
  ];
  extraConfigLua = "require('${name}').setup ${toLuaObject pluginOptions}";
  defaultRequire = false;
}
