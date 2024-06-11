{ pkgs, lib, helpers, ... }:

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "nvim-tree";
  pluginUrl = "https://github.com/nvim-tree/nvim-tree.lua";

  # only needed when the name of the name of the module/plugin does not match the
  # name in the 'require("<...>")' call. For example, the plugin 'comment-frame'
  # has to be called with 'require("nvim-comment-frame")'
  # pluginName = ""

  inherit (helpers.custom_options)
    strOption
    listOption
    enumOption
    intOption
    boolOption;
  inherit (lib)
    mkOption
    types;

  moduleOptions = {
    # add module options here
    disableNetrw = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Disable netrw";
    };

    hijackNetrw = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Hijack netrw";
    };

    openOnSetup = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Open on setup";
    };

    ignoreFtOnSetup = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
    };

    autoClose = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Automatically close";
    };

    openOnTab = mkOption {
      type = types.nullOr types.bool;
      default = null;
    };

    hijackCursor = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Hijack cursor";
    };

    updateCwd = mkOption {
      type = types.nullOr types.bool;
      default = null;
    };

    syncRootWithCwd = mkOption {
      type = types.nullOr types.bool;
      default = null;
    };

    hijackDirectories = {
      enable = mkOption {
        type = types.nullOr types.bool;
        default = null;
      };

      autoOpen = mkOption {
        type = types.nullOr types.bool;
        default = null;
      };
    };

    diagnostics = {
      enable = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Enable diagnostics";
      };

      icons =
        let
          diagnosticOption = desc: mkOption {
            type = types.nullOr types.str;
            default = null;
            description = desc;
          };
        in
        {
          hint = diagnosticOption "Hints";
          info = diagnosticOption "Info";
          warning = diagnosticOption "Warning";
          error = diagnosticOption "Error";
        };
    };

    updateFocusedFile = {
      enable = mkOption {
        type = types.nullOr types.bool;
        default = null;
      };

      updateCwd = mkOption {
        type = types.nullOr types.bool;
        default = null;
      };

      ignoreList = mkOption {
        type = types.nullOr (types.listOf types.bool);
        default = null;
      };
    };

    systemOpen = {
      cmd = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      args = mkOption {
        type = types.nullOr (types.listOf types.str);
        default = null;
      };
    };

    git = {
      enable = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Enable git integration";
      };

      ignore = mkOption {
        type = types.nullOr types.bool;
        default = null;
      };

      timeout = mkOption {
        type = types.nullOr types.int;
        default = null;
      };
    };

    filters = {
      dotfiles = mkOption {
        type = types.nullOr types.bool;
        default = null;
      };
      custom = mkOption {
        type = types.nullOr (types.listOf types.str);
        default = null;
      };
    };

    view = {
      width = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      height = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      hideRootFolder = mkOption {
        type = types.nullOr types.bool;
        default = null;
      };
      side = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      autoResize = mkOption {
        type = types.nullOr types.bool;
        default = null;
      };
      number = mkOption {
        type = types.nullOr types.bool;
        default = null;
      };
      relativenumber = mkOption {
        type = types.nullOr types.bool;
        default = null;
      };
      signcolumn = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };

    trash = {
      cmd = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      requireConfirm = mkOption {
        type = types.nullOr types.bool;
        default = null;
      };
    };
  };



in mkLuaPlugin {

# Consider the following additional options:
#
# extraDescription ? ""           # description added to the enable function
# extraPackages ? [ ]             # non-plugin packages
# extraConfigLua ? ""             # lua config added to the init.vim
# extraConfigVim ? ""             # vim config added to the init.vim
# defaultRequire ? true           # add default requrie string?
# extraOptions ? {}               # extra vim options like line numbers, etc
# extraNixNeovimConfig ? {}       # extra config applied to 'programs.nixneovim'
# isColorscheme ? false           # If enabled, plugin will be added to 'nixneovim.colorschemes' instead of 'nixneovim.plugins'
# configConverter ? camelToSnake  # Specify the config name converter, default expects camelCase and converts that to snake_case

  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    nvim-tree-lua
    nvim-web-devicons
  ];
}
