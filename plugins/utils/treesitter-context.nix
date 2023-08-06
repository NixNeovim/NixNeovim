{ pkgs, lib, config, ... }:

with lib;

let

  name = "treesitter-context";
  pluginUrl = "https://github.com/nvim-treesitter/nvim-treesitter-context";

  helpers = import ../../helper { inherit pkgs lib config; };
  cfg = config.programs.nixneovim.plugins.${name};
  inherit (helpers.customOptions) intNullOption enumOption;
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

  # you can autogenerate the plugin options from the moduleOptions.
  # This essentially converts the camalCase moduleOptions to snake_case plugin options
  pluginOptions = helpers.convertModuleOptions cfg moduleOptions;

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    nvim-treesitter-context
  ];
}
