{ pkgs, lib, helpers, config }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  inherit (helpers.converter)
    flattenModuleOptions
    toLuaObject;

  name = "lspkind";
  pluginUrl = "https://github.com/onsails/lspkind.nvim";

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
  pluginOptions = flattenModuleOptions cfg moduleOptions;

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    lspkind-nvim
  ];

  extraConfigLua = "require('${name}').init ${toLuaObject pluginOptions}";
  defaultRequire = false;
}
