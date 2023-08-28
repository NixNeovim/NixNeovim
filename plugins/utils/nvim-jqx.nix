{ pkgs, lib, helpers, config }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "nvim-jqx";
  pluginUrl = "https://github.com/gennaro-tedesco/nvim-jqx";

  cfg = config.programs.nixneovim.plugins.${name};
  inherit (helpers.custom_options) boolOption strOption;

  moduleOptions = {
    sort = boolOption false "Sort keys alphabetical";
    queryKey = strOption "X" "Key to open query in floating window";
    closeWindowKey = strOption "<ESC>" "Key to close floating window";
    useQuickfix = boolOption true "Use location list instead of quickfix";
  };

  pluginOptions = mapAttrsToList
    (key: _option:
      let
        value = cfg.${key};
      in
      if isBool value then
        "jqx.${key} = ${boolToString value}"
      else
        "jqx.${key} = \"${toString value}\""
    )
    moduleOptions;

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    nvim-jqx
  ];
  extraPackages = with pkgs; [
    jq
  ];
  extraConfigLua = ''
    local jqx = require("${name}.config")
    ${concatStringsSep "\n" pluginOptions}
  '';
  defaultRequire = false;
}
