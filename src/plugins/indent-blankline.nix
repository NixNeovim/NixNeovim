{ pkgs, lib, helpers, config, ... }:

with lib;

let

  inherit (helpers.generator)
     mkLuaPlugin;
  inherit (helpers.custom_options) boolOption;
  inherit (helpers.converter)
    toLuaObject
    camelToSnake
    flattenModuleOptions;

  name = "indent-blankline";
  pluginName = "ibl";
  pluginUrl = "https://github.com/lukas-reineke/indent-blankline.nvim";

  moduleOptions = {
    indent = mkOption {
      default = {};
      type = types.submodule {
        options = with types; {
          char = mkOption {
            type = either str (listOf str);
            default = "▎";
            description = ''
                           Character, or list of characters, that get used to
                           display the indentation guide
                           Each character has to have a display width of 0 or 1
                          '';
          };
          highlight = mkOption {
            type = nullOr (either str (listOf str));
            default = null;
            description = "Highlight group or color, or list of highlight groups and colors.";
          };
          smartIndentCap = boolOption true "Caps the number of indentation levels by looking at the surrounding code";
          repeatLinebreak = boolOption true "Repeat indentation guide on wrapped lines.";
        };
      };
    };
    scope = mkOption {
      default = {};
      type = types.submodule {
        options = with types; {
          enabled = boolOption true "Enable scope highlighting.";
          char = mkOption {
            type = nullOr (either str (listOf str));
            default = null;
            description = ''
                           Character, or list of characters, that get used to
                           display the scope indentation guide
                           Each character has to have a display width
                           of 0 or 1
                          '';
          };
          showStart = boolOption true "Underline first line of scope.";
          showEnd = boolOption true "Underline last line of scope";
          highlight = mkOption {
            type = nullOr (either str (listOf str));
            default = null;
            description = "Highlight group or color, or list of highlight groups and colors.";
          };
        };
      };
    };
  };
  # functions to build config
  mkList = arg: if builtins.isList arg then arg else [ arg ];
  replaceColorsByName = map (e: if builtins.isList (builtins.match "#[A-Fa-f0-9]{6}" e) then "Ibl${removePrefix "#" e}" else e);
  colors = builtins.filter (e: builtins.isList (builtins.match "#[A-Fa-f0-9]{6}" e));
  nullToEmpty = a: if a == null then [] else a;

  cfg = config.programs.nixneovim.plugins.${name};
  patchedCfg = (flattenModuleOptions cfg moduleOptions) // {
    indent = cfg.indent // { highlight = if cfg.indent.highlight == null then null else replaceColorsByName (mkList cfg.indent.highlight); };
    scope = cfg.scope // { highlight = if cfg.scope.highlight == null then null else replaceColorsByName (mkList cfg.scope.highlight); };
  };
  setHlStrings = map (color: "vim.api.nvim_set_hl(0, \"Ibl${removePrefix "#" color}\", { fg = \"${color}\" })") (unique (colors (mkList (nullToEmpty cfg.indent.highlight) ++ mkList (nullToEmpty cfg.scope.highlight))));
  createHlString = ''
    local hooks = require "ibl.hooks"
    -- create the highlight groups in the highlight setup hook, so they are reset
    -- every time the colorscheme changes
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        ${builtins.concatStringsSep "\n      " setHlStrings}
    end)
  '';

in mkLuaPlugin {
  inherit name pluginName moduleOptions pluginUrl;
  defaultRequire = false;
  extraConfigLua = ''
    ${optionalString (setHlStrings != []) createHlString}
    require('${pluginName}').setup ${toLuaObject { nameConverter = camelToSnake; nixExpr = patchedCfg; }}
  '';
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    indent-blankline-nvim
  ];
}
