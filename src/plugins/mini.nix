{ pkgs, lib, helpers, super, config }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;
  inherit (helpers.converter)
    toNeovimConfigString
    flattenModuleOptions;

  name = "mini";
  pluginUrl = "https://github.com/echasnovski/mini.nvim";

  cfg = config.programs.nixneovim.plugins.${name};

  # TODO: move to files and add options
  modules = {
    ai = super.mini-modules.ai;
    align = { };
    animate = { };
    base16 = { };
    basics = { };
    bracketed = { };
    bufremove = { };
    clue = { };
    colors = { };
    comment = { };
    completion = { };
    cursorword = { };
    doc = { };
    files = { };
    fuzzy = { };
    hlpatterns = { };
    hues = { };
    indentscope = { };
    jump = { };
    jump2d = { };
    map = { };
    misc = { };
    move = { };
    operators = { };
    pairs = { };
    sessions = { };
    splitjoin = { };
    starter = { };
    statusline = { };
    surround = { };
    tabline = super.mini-modules.tabline;
    test = { };
    trailspace = { };
  };

  # convert module list to module set for cfg
  # - adds the enable option
  # - adds the extraConfig Option
  moduleOptions = mapAttrs
    (module: config:
      config // {
        enable = mkEnableOption "Enable mini.${module}";
        extraConfig = mkOption {
          type = types.attrs;
          default = { };
          description = "Place any extra config here as an attibute-set";
        };
      }
    )
    modules;

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    mini-nvim
  ];
  extraConfigLua =
    let
      setup = mapAttrsToList
        (module: options:
          let
            # combine the lua configs with their values from the nix-module config value and add extraConfig
            setup = flattenModuleOptions cfg.${module} (options // { extraConfig = { }; });
          in
          if cfg.${module}.enable then
            "require('${name}.${module}').setup(${helpers.converter.toLuaObject setup})"
          else
            ""
        )
        modules;
    in toNeovimConfigString setup;

  defaultRequire = false;
}
