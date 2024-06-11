{ pkgs, lib, helpers, config, ... }:

let

  inherit (helpers.generator)
     mkLuaPlugin;

  name = "zig-env";
  pluginUrl = "";

  cfg = config.programs.nixneovim.plugins.${name};

  # only needed when the name of the plugin does not match the
  # name in the 'require("<...>")' call. For example, the plugin 'comment-frame'
  # has to be called with 'require("nvim-comment-frame")'
  # in such a case add 'pluginName = "nvim-comment-frame"'
  # pluginName = ""

  inherit (helpers.custom_options)
    intOption
    boolOptionStrict;

  inherit (lib)
    mkIf;

  moduleOptionsVim = {
    # add module options here
    fmtAutosave = intOption 0 "If set to 1 enabled automatic code formatting on save";
  };
  moduleOptions = {
    lsp = boolOptionStrict true "Enable the zls language server for zig";
  };

in mkLuaPlugin {
  inherit name moduleOptionsVim moduleOptions pluginUrl;
  extraDescription = "This is all-in-one-module for plugins regarding the zig language.";
  extraPlugins = with pkgs.vimExtraPlugins; [
    zig-vim
  ];
  defaultRequire = false;
  moduleOptionsVimPrefix = "zig_";

  extraNixNeovimConfig = {
    plugins.lspconfig = mkIf cfg.lsp {
      enable = true;
      servers.zls.enable = true;
    };
  };
}
