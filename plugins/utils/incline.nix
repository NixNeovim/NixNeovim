{ pkgs
, lib
, config
, ...
}:
with lib;
let
  name = "incline";
  pluginUrl = "https://github.com/b0o/incline.nvim";

  helpers = import ../helpers.nix { inherit lib config; };
  cfg = config.programs.nixvim.plugins.${name};

  moduleOptions = with helpers; {
  };

  pluginOptions = helpers.toLuaOptions cfg moduleOptions;
in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    incline-nvim
  ];
  extraConfigLua = "require('${name}').setup ${toLuaObject pluginOptions}";
}
