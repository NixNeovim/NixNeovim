{ pkgs, lib, config, ... }:

with lib;

let

  name = "snippy";
  pluginUrl = "https://github.com/dcampos/nvim-snippy";

  helpers = import ../helpers.nix { inherit lib config; };
  cfg = config.programs.nixneovim.plugins.${name};

  moduleOptions = with helpers; {
    mappings = mkOption {
      type = types.attrs;
      default = { };
    };
    enableAuto = boolOption false "Enable auto expanding snippets";
  };

  pluginOptions = helpers.toLuaOptions cfg moduleOptions;

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    nvim-snippy
  ];
  extraConfigLua = "require('${name}').setup ${toLuaObject pluginOptions}";
}
