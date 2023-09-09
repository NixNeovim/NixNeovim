{ pkgs, lib, helpers, ... }:

with lib;
with types;
let

  toLua = cfg: server: serverAttrs:
    let

      serverName = serverAttrs.serverName;

      setup =
        let
          coqRequire = optionalString cfg.coqSupport "local coq = require(\"coq\")";
          coqCapabilities = optionalString cfg.coqSupport "coq.lsp_ensure_capabilities";
          extraConfig = cfg.servers.${server}.extraConfig;
        in
        ''
          ${coqRequire}
          local setup = ${coqCapabilities} {
            on_attach = function(client, bufnr)
              ${optionalString (cfg.onAttach != "") "on_attach_global(client, bufnr)" }
              ${optionalString (cfg.servers.${server}.onAttachExtra != "") "on_attach_client(client, bufnr)" }
            end,
            ${optionalString (extraConfig != null) extraConfig}
          }
        '';

        onAttachExtra =
          ''
            local on_attach_client = function(client, bufnr)
              ${cfg.servers.${server}.onAttachExtra}
            end
          '';

    in
    ''
      do -- lsp server config ${server}
        ${optionalString (cfg.servers.${server}.onAttachExtra != "") onAttachExtra}
        ${setup}
        require('lspconfig')["${serverName}"].setup(setup)
      end -- lsp server config ${server}
    '';

in
{

  # create the lua code to activate the lsp server
  serversToLua = cfg: servers:
    mapAttrsToList (toLua cfg) servers;

}
