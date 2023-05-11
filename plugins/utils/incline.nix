{ pkgs
, lib
, config
, ...
}:
with lib;
let
  name = "incline";
  pluginUrl = "https://github.com/b0o/incline.nvim";

  helpers = import ../../helper { inherit pkgs lib config; };
  cfg = config.programs.nixneovim.plugins.${name};

  moduleOptions = with helpers; {
  };

  pluginOptions = helpers.convertModuleOptions cfg moduleOptions;
in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    incline-nvim
  ];
  # extraConfigLua = "require('${name}').setup ${toLuaObject pluginOptions}";
}
