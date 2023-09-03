{ pkgs, lib, helpers, ... }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "gitsigns";
  pluginUrl = "https://github.com/lewis6991/gitsigns.nvim";

  inherit (helpers.custom_options)
    boolOption
    enumOption
    intOption;

  moduleOptions = {
    signcolumn = boolOption true "Can be toggled with `:Gitsigns toggle_signs`";
    numhl = boolOption false "Highlight line number. Can be toggled with `:Gitsigns toggle_numhl`";
    linehl = boolOption false "Highlgiht complete line. Can be toggled with `:Gitsigns toggle_linehl`";
    wordDiff = boolOption false "Can be toggled with `:Gitsigns toggle_word_diff`";
    currentLineBlame = boolOption false "Can be toggled with `:Gitsigns toggle_current_line_blame`";
    currentLineBlameOpts = {
      virtText = boolOption true "";
      virtTextPos = enumOption [ "eol" "overlay" "right_align" ] "eol" "";
      delay = intOption 1000 "Delay in seconds";
      ignoreWhitespace = boolOption false "";
    };
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    gitsigns-nvim
  ];
  extraPackages = with pkgs; [
    git
  ];
}
