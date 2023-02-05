{ pkgs, lib, config, ... }:

with lib;

let

  name = "nvim-lightbulb";
  pluginUrl = "https://github.com/kosayoda/nvim-lightbulb";

  helpers = import ../helpers.nix { inherit lib config; };

  moduleOptions = with helpers; {
    # add module options here
    ignore = attrsOption {} "LSP client names to ignore";
    sign = {
      enable = boolOption true "";
      priority = intOption 10 "Priority of the gutter sign";
    };
    virtual_text = {
        enabled = boolOption false "";
        text = strOption "💡" "Text to show at virtual text";
        hlMode = enumOption [ "replace" "combine" "blend" ] "replace" "highlight mode to use for virtual text (replace, combine, blend), see :help nvim_buf_set_extmark() for reference";
    };
  };

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    nvim-lightbulb
  ];
}
