{ pkgs, lib, config, ... }:

with lib;

let

  name = "snippy";

  helpers = import ../helpers.nix { inherit lib config; };
  cfg = config.programs.nixvim.plugins.${name};

  moduleOptions = with helpers; {
    mappings = mkOption {
      type = types.attrs;
      default = {};
    };
    enableAuto = boolOption false "Enable auto expanding snippets";
  };

  pluginOptions = helpers.toLuaOptions cfg moduleOptions;

in with helpers;
mkLuaPlugin {
  inherit name moduleOptions;
  description = "Enable ${name}.nvim";
  extraPlugins = with pkgs.vimExtraPlugins; [ 
    nvim-snippy
  ];
  extraConfigLua = "require('${name}').setup ${toLuaObject pluginOptions}";
}
