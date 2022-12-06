{ pkgs, lib, config, ... }:

with lib;

let

  name = "copilot";
  pluginUrl = "https://github.com/github/copilot.vim";

  helpers = import ../helpers.nix { inherit lib config; };
  cfg = config.programs.nixvim.plugins.${name};

  moduleOptions = with helpers; {
    # add module options here

    filestypes = mkOption {
      type = types.attrsOf types.bool;
      description = "Attribute set of file types";
      default = { };
      example = literalExpression ''{
        "*": false,
        python: true
      }'';
    };

    proxy = mkOption {
      type = types.nullOr types.str;
      description = "Address of proxy server for Copilot";
      default = null;
      example = "localhost:3128";
    };
  };

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    copilot-vim
  ];
  defaultRequire = false;
  extraConfigVim =
    let
      proxy =
        if cfg.proxy != null then
          "let g:copilot_proxy = ${cfg.proxy}"
        else "";
    in ''
      let g:copilot_node_command = ${pkgs.node-16_x}/bin/node
      let g:copilot_filetypes = ${cfg.filetypes}
      ${proxy}
    '';
}
