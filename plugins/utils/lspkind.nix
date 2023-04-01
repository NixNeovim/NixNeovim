{ pkgs, lib, config, ... }:

with lib;

let

  name = "lspkind";
  pluginUrl = "https://github.com/onsails/lspkind.nvim";

  helpers = import ../../helper { inherit pkgs lib config; };
  cfg = config.programs.nixneovim.plugins.${name};

  moduleOptions = with helpers; {
    mode = mkOption {
      type = types.enum [ "text" "text_symbol" "symbol_text" "symbol" ];
      description = "Defines how annotations are shown";
      default = "symbol_text";
    };
  };

  # you can autogenerate the plugin options from the moduleOptions.
  # This essentially converts the camalCase moduleOptions to snake_case plugin options
  pluginOptions = helpers.convertModuleOptions cfg moduleOptions;

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    lspkind-nvim
  ];

  extraConfigLua = "require('${name}').init ${toLuaObject pluginOptions}";
}
