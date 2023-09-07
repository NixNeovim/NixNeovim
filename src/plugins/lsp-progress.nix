{ pkgs, lib, helpers, ... }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "lsp-progress";
  pluginUrl = "https://github.com/linrongbin16/lsp-progress.nvim";

   inherit (helpers.custom_options) intOption listOption;

  moduleOptions = {
    # add module options here
    spinner = listOption [ "⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷" ] "Spinning icon array";
    spinUpdateTime = intOption 200 "Spinning update time in milliseconds";
    decay = intOption 1000 "Message decay in milliseconds";
    maxSize = intOption (-1) "Max string length, -1 is unlimited";
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    lsp-progress-nvim
  ];
}
