{ pkgs, lib, config, ... }:

with lib;

let

  name = "nvim-jqx";

  helpers = import ../helpers.nix { inherit lib config; };
  cfg = config.programs.nixvim.plugins.${name};

  moduleOptions = with helpers; {
    sort = boolOption false "Sort keys alphabetical";
    queryKey = strOption "X" "Key to open query in floating window";
    closeWindowKey = strOption "<ESC>" "Key to close floating window";
    useQuickfix = boolOption true "Use location list instead of quickfix";
  };

  # pluginOptions = helpers.toLuaOptions cfg moduleOptions;
  pluginOptions = mapAttrsToList (key: _option:
    let
      value = cfg.${key};
    in if isBool value then
      "jqx.${key} = ${boolToString value}"
    else 
      "jqx.${key} = \"${toString value}\""
  ) moduleOptions;

in with helpers;
mkLuaPlugin {
  inherit name moduleOptions;
  description = "Enable ${name}.nvim";
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
}
