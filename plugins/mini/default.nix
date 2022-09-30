{ pkgs, lib, config, ... }:

with lib;

let

  name = "mini";

  helpers = import ../helpers.nix { inherit lib config; };
  cfg = config.programs.nixvim.plugins.${name};

  modules = {
    align = import ./modules/align.nix { inherit lib helpers; };
    sessions = import ./modules/sessions.nix { inherit lib helpers; };
    ai = import ./modules/ai.nix { inherit lib helpers; }; # this is better if there are many options
    comment = { setup = true; options = {}; }; # TODO: move to file and add options
    starter = { setup = true; options = {}; }; # TODO: move to tile and add options
    cursorword = { setup = true; options = {}; }; # TODO: move to tile and add options
    surround = { setup = true; options = {}; }; # TODO: move to tile and add options
  };

  # convert module list to module set for cfg
  # - adds the enable option
  # - adds the extraConfig Option
  moduleOptions = mapAttrs (module: config: 
      config.options // {
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
  # extraPackages = with pkgs; [
  #   # add dependencies here
  #   # tree-sitter
  # ];
  extraConfigLua = let
    setup = mapAttrsToList (module: options:
      let
        # add extraConfig to lua Options
        lua-options = options.options // { extraConfig = {}; };
        # combine the lua configs with their values from the nix-module config value
        setup = helpers.toLuaOptions cfg.${module} lua-options;
      in if cfg.${module}.enable then
        "require('${name}.${module}').setup(${helpers.toLuaObject setup})"
      else 
        ""
    ) modules;
  in concatStringsSep "\n" setup;
}
