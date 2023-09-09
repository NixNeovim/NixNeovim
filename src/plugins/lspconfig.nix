{ pkgs, lib, helpers, config, super }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  inherit (helpers.converter)
    toNeovimConfigString;

  name = "lspconfig";
  pluginUrl = "https://github.com/neovim/nvim-lspconfig";

  cfg = config.programs.nixneovim.plugins.${name};
  lsp-helpers = super.lspconfig-modules.lsp-helpers;
  servers = super.lspconfig-modules.servers;

  moduleOptions = {
    servers = servers.options;

    onAttach = mkOption {
      type = types.lines;
      description = "A lua function to be run when a new LSP buffer is attached. The argument `client` and `bufnr` is provided.";
      default = "";
    };

    coqSupport = mkOption {
      type = types.bool;
      description = "Coq requires a special LSP setup (https://github.com/ms-jpq/coq_nvim#lsp). This automatically set to true when activating the coq plugin.";
      default = false;
    };

    preConfig = mkOption {
      type = types.lines;
      description = "Code to be run before loading the LSP plugin. Useful for requiring plugins";
      default = "";
    };
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    nvim-lspconfig
  ];
  extraPackages = servers.packages cfg.servers;
  extraConfigLua =
    let
      # create lua code for lsp server, with setup wrapper
      serversLua = lsp-helpers.serversToLua cfg (servers.activated cfg.servers);

      globalOnAttachFunction =
        ''
          local on_attach_global = function(client, bufnr)
            ${cfg.onAttach}
          end
        '';
    in
    ''
      ${optionalString (cfg.onAttach != "") globalOnAttachFunction}
      ${cfg.preConfig}
      ${toNeovimConfigString serversLua}
    '';
    defaultRequire = false;
}
