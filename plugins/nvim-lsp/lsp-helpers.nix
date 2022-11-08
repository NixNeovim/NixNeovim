{ pkgs, config, lib, ... }:

with lib;
with types;
let
  helpers = import ../helpers.nix { inherit lib config; };

  toLua = cfg: server: serverAttrs:
    let

      serverName = serverAttrs.serverName;
        
      onAttach =
        ''
          local __on_attach = function(client, bufnr)
            ${cfg.servers.${server}.onAttachExtra}
          end
        '';

      setup =
        let
          coqRequire = optionalString cfg.coqSupport "local coq = require(\"coq\")";
          coqCapabilities = optionalString cfg.coqSupport "coq.lsp_ensure_capabilities";
        in ''
            ${coqRequire}
            local __setup = ${coqCapabilities} {
              on_attach = __on_attach,
              ${cfg.servers.${server}.extraConfig}
            }
          '';

    in ''
        do -- lsp server config ${server}
          ${onAttach}
          ${setup}
          require('lspconfig')["${serverName}"].setup(__setup)
        end -- lsp server config ${server}
      '';
  
in {

  # create the lua code to activate the lsp server
  serversToLua = cfg: servers:
    mapAttrsToList (toLua cfg) servers;

}
