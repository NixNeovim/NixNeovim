{ pkgs, lib, config, ... }:

with lib;

let

  name = "gitsigns";
  pluginUrl = "https://github.com/lewis6991/gitsigns.nvim";

  helpers = import ../../helper { inherit pkgs lib config; };
  inherit (helpers.customOptions)
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

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    gitsigns-nvim
  ];
}
