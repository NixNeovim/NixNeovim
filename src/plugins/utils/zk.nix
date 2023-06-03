{ pkgs, lib, config, ... }:

with lib;

let

  name = "zk";
  pluginUrl = "https://github.com/mickael-menu/zk-nvim";

  helpers = import ../../helper { inherit pkgs lib config; };
  inherit (helpers.customOptions)
    enumOption
    listOption
    strOption
    boolOption;

  moduleOptions = {
    # add module options here
    # can be "telescope", "fzf" or "select" (`vim.ui.select`)
    # it's recommended to use "telescope" or "fzf"
    picker = enumOption [ "telescope" "fzf" "select" ] "select" "it's recommended to use \"telescope\" or \"fzf\"";
    lsp = {
      # `config` is passed to `vim.lsp.start_client(config)`
      config = {
        cmd = listOption [ "zk" "lsp" ] "";
        name = strOption "zk" "`config` is passed to `vim.lsp.start_client(config)`";
      };
      # automatically attach buffers in a zk notebook that match the given filetypes
      autoAttach = {
        enabled = boolOption true "automatically attach buffers in a zk notebook that match the given filetypes";
        filetypes = listOption [ "markdown" ] "";
      };
    };
  };

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    zk-nvim
  ];
}
