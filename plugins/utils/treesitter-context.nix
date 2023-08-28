{ pkgs, lib, helpers, ... }:

let
  inherit (helpers.generator)
     mkLuaPlugin;

  inherit (lib)
    mkOption;

  name = "treesitter-context";
  pluginUrl = "https://github.com/nvim-treesitter/nvim-treesitter-context";

  inherit (helpers.custom_options)
    intNullOption
    enumOption;

  inherit (lib.types) enum listOf;

  moduleOptions = {
    # add module options here
    #
    # autoStart = boolOption true "Enable this pugin at start"
    maxLines = intNullOption "Define the limit of context lines. 0 means no limit";
    trimScope = enumOption [ "inner" "outer" ] "outer" "When max_lines is reached, which lines to discard";
    mode = enumOption [ "cursor" "topline" ] "cursor" "Which context to show";
    patterns = {
      default = mkOption {
        type = listOf (enum [
          "class"
          "function"
          "method"
          "for"
          "while"
          "if"
          "switch"
          "case"
        ]);
        description = "Which Treesitter nodes to consider";
        default = [ "class" "function" "method" ];
      };
    };
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    nvim-treesitter-context
  ];
}
