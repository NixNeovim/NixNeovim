{ pkgs, lib, helpers, config }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  inherit (helpers.converter)
    flattenModuleOptions
    toLuaObject;

  name = "which-key";
  pluginUrl = "https://github.com/folke/which-key.nvim";

  cfg = config.programs.nixneovim.plugins.${name};

  inherit (helpers.custom_options)
    boolOption
    intOption
    strOption
    enumOption;

  groupOptions = mode: mkOption {
    description = "Groups for ${mode} mode";
    type = types.attrsOf types.str;
    default = { };
  };

  groupsByMode = {
    "" = cfg.groups.normalVisualOp;
    n = cfg.groups.normal // cfg.groups.normalVisualOp;
    i = cfg.groups.insert // cfg.groups.insertCommand;
    v = cfg.groups.visual // cfg.groups.normalVisualOp;
    x = cfg.groups.visualOnly;
    s = cfg.groups.select;
    t = cfg.groups.terminal;
    o = cfg.groups.operator // cfg.groups.normalVisualOp;
    c = cfg.groups.command // cfg.groups.insertCommand;
  };

  groupsString =
    with builtins; with lib;
    let
      string = groups: concatStringsSep ",\n  " (attrValues (mapAttrs
        (keys: name: ''["${keys}"] = { name = "${name}" }'') groups
      ));
    in concatStringsSep "" (attrValues (mapAttrs
      (mode: groups: optionalString (stringLength (string groups) > 0) ''
        wk.register({
          ${string groups}
        }, { mode = "${mode}" })
      '')
      groupsByMode
    ));

  moduleOptions = with helpers; {
    plugins = {
      marks = boolOption true "Show a list of your marks on ' and `.";
      registers = boolOption true "Show your registers on \" in NORMAL or &lt;C-r&gt; in INSERT mode.";
      spelling = {
        enabled = boolOption false "Enable showing WhichKey when pressing z= to select spelling suggestions.";
        suggestions = intOption 20 "Number of suggestions to show in the spelling suggestion list.";
      };
      presets = {
        operators = boolOption true "Add help for operators like d, y, ... and register them for motion / text object completion.";
        motions = boolOption true "Add help for motions.";
        textObjects = boolOption true "Add help for text objects triggered after entering an operator.";
        windows = boolOption true "Add help for default bindings on &lt;c-w&gt;.";
        nav = boolOption true " Add help for misc bindings to work with windows.";
        z = boolOption true "Add help for bindings for folds, spelling and others prefixed with z.";
        g = boolOption true "Add help for bindings prefixed with g.";
      };
    };
    popupMappings = {
      scrollDown = strOption "<c-d>" "Binding to scroll down inside the popup.";
      scrollUp = strOption "<c-u>" "Binding to scroll up inside the popup.";
    };
    window = {
      border = enumOption [ "none" "single" "double" "shadow"] "none" "";
      position = enumOption [ "bottom" "top" ] "bottom" "";
    };
    disable = {
      buftypes = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Buf types for which Whichkey should be disabled.";
      };
      filetypes = mkOption {
        type = types.listOf types.str;
        default = [ "TelescopePrompt" ];
        description = "File types for which Whichkey should be disabled.";
      };
    };
    groups = mkOption {
      type = types.submodule {
        options = {
          normal = groupOptions "normal";
          insert = groupOptions "insert";
          select = groupOptions "select";
          visual = groupOptions "visual and select";
          terminal = groupOptions "terminal";
          normalVisualOp = groupOptions "normal, visual, select and operator-pending (same as plain 'map')";

          visualOnly = groupOptions "visual only";
          operator = groupOptions "operator-pending";
          insertCommand = groupOptions "insert and command-line";
          lang = groupOptions "insert, command-line and lang-arg";
          command = groupOptions "command-line";
        };
      };
      default = { };
      description = "Assign names to groups of keybindings with the same prefix to be shown in which-key.";
      example = literalExpression ''{
          normal."<leader>g" = "git" # name group of bindings with prefix <leader>g "git" in normal mode
          visual."<leader>f" = "find"
        }
      '';
    };
  };

  pluginOptions = flattenModuleOptions cfg (builtins.removeAttrs moduleOptions [ "groups" ]);

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;

  extraPlugins = with pkgs.vimExtraPlugins; [
    which-key-nvim
  ];

  defaultRequire = false;

  extraConfigLua = ''
    local wk = require('which-key')
    wk.setup ${toLuaObject pluginOptions}

    -- group names
    ${groupsString}
  '';
}
