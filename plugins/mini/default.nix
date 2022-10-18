{ pkgs, lib, config, ... }:

with lib;

let

  name = "mini";

  helpers = import ../helpers.nix { inherit lib config; };
  cfg = config.programs.nixvim.plugins.${name};

  # TODO: move to files and add options
  modules = {
    ai         = import ./modules/ai.nix { inherit lib helpers; };
    align      = { };
    base16     = { };
    bufremove  = { };
    comment    = { };
    completion = { };
    cursorword = { };
    doc        = { };
    fuzzy      = { };
    identscope = { };
    jump       = { };
    jump2d     = { };
    map        = { };
    misc       = { };
    pairs      = { };
    sessions   = { };
    starter    = { };
    statusline = { };
    surround   = { };
    tabline    = { };
    test       = { };
    trailspace = { };
  };

  # convert module list to module set for cfg
  # - adds the enable option
  # - adds the extraConfig Option
  moduleOptions = mapAttrs (module: config:
      config // {
        enable = mkEnableOption "Enable mini.${module}";
          extraConfig = mkOption {
            type = types.attrs;
            default = {};
            description = "Place any extra config here as an attibute-set";
          };
      }
    ) modules;

  # pluginOptions = helpers.toLuaOptions cfg moduleOptions;

in with helpers;
mkLuaPlugin {
  inherit name moduleOptions;
  description = "Enable ${name}.nvim";
  extraPlugins = with pkgs.vimExtraPlugins; [
    mini-nvim
  ];
  extraPackages = with pkgs; [
  #   # add dependencies here
  #   # tree-sitter
  ];
  extraConfigLua = let
    setup = mapAttrsToList (module: options:
      let
        # combine the lua configs with their values from the nix-module config value and add extraConfig
        setup = helpers.toLuaOptions cfg.${module} ( options // { extraConfig = {}; });
      in if cfg.${module}.enable then
        "require('${name}.${module}').setup(${helpers.toLuaObject setup})"
      else
        ""
    ) modules;
  in concatStringsSep "\n" setup;
}
