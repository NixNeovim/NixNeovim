{ pkgs, lib, helpers, ... }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "snippy";
  pluginUrl = "https://github.com/dcampos/nvim-snippy";

  cfg = config.programs.nixneovim.plugins.${name};
  inherit (helpers.custom_options) boolOption;

  moduleOptions = {
    mappings = mkOption {
      type = types.attrs;
      default = { };
    };
    enableAuto = boolOption false "Enable auto expanding snippets";
  };

  pluginOptions = helpers.convertModuleOptions cfg moduleOptions;

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    nvim-snippy
  ];
}
