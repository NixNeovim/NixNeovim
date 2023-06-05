{ pkgs, config, lib, ... }:

with lib;
with types;
let
  helpers = import ../../helper { inherit pkgs lib config; };

  toLua = cfg: server: serverAttrs:
    let

      serverName = serverAttrs.serverName;

      setup =
        let
          coqRequire = optionalString cfg.coqSupport "local coq = require(\"coq\")";
          coqCapabilities = optionalString cfg.coqSupport "coq.lsp_ensure_capabilities";
        in
        ''
          ${coqRequire}
          local __setup = ${coqCapabilities} {
            on_attach = function(client, bufnr)
              ${optionalString (cfg.onAttach != "") "__on_attach_base(client, bufnr)" }
              ${optionalString (cfg.servers.${server}.onAttachExtra != "") "__on_attach_extra(client, bufnr)" }
            end,
            ${cfg.servers.${server}.extraConfig}
          }
        '';

        onAttach =
          ''
            local __on_attach_base = function(client, bufnr)
              ${cfg.onAttach}
            end
          '';

        onAttachExtra =
          ''
            local __on_attach_extra = function(client, bufnr)
              ${cfg.servers.${server}.onAttachExtra}
            end
          '';

    in
    ''
      do -- lsp server config ${server}
        ${optionalString (cfg.onAttach != "") onAttach}
        ${optionalString (cfg.servers.${server}.onAttachExtra != "") onAttachExtra}
        ${setup}
        require('lspconfig')["${serverName}"].setup(__setup)
      end -- lsp server config ${server}
    '';

in
{

  # create the lua code to activate the lsp server
  serversToLua = cfg: servers:
    mapAttrsToList (toLua cfg) servers;

}
