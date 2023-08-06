{ pkgs, lib, config, ... }:

with lib;

let

  name = "luasnip";
  pluginUrl = "https://github.com/L3MON4D3/LuaSnip";

  helpers = import ../../helper { inherit pkgs lib config; };
  cfg = config.programs.nixneovim.plugins.${name};
  inherit (helpers.customOptions) boolOption strOption;

  moduleOptions = {
    # add module options here
    enableSnipmate = boolOption true "Load Snimate snippets";
    enableLua = boolOption true "Load LuaSnip snippets";
    lazyLoad = boolOption true "lazy load snippets";
    path = strOption "./snippets" "Specifies the path where snippets are loaded from";
  };

  inherit (helpers.toLua)
    mkLuaPlugin;

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    LuaSnip
  ];
  extraPackages = with pkgs; [
    # add dependencies here
    luajitPackages.jsregexp
  ];
  extraConfigLua =
    let
      load-call =
        let
          paths = optionalString (cfg.path != null) "{ paths = \"${cfg.path}\" }";
        in if cfg.lazyLoad then
          "lazy_load(${paths})"
        else
          "load(${paths})";
    in lib.concatStringsSep "\n" [
      (optionalString (cfg.enableSnipmate != null && cfg.enableSnipmate) "require('${name}.loaders.from_snipmate').${load-call}")
      (optionalString (cfg.enableLua != null && cfg.enableLua) "require('${name}.loaders.from_lua').${load-call}")
    ];
  defaultRequire = false;
}
