{ lib, config, pkgs, ... }:

with lib;
with types;

let

  helpers = import ../../helpers.nix { inherit lib config; };
  servers = import ../servers.nix { inherit pkgs; };

  # this function expects all fields of `server` to be filled
  toLspModule = server:
    with helpers;
    let
      cfg = config.programs.nixvim.plugins.lsp.servers.${server.serverName};
    in mkOption {
      type = nullOr (submodule {
        options = {
          enable = mkEnableOption "";
          onAttachExtra = mkOption {
            type = types.lines;
            description = "A lua function to be run when ${server.name} is attached. The argument `client` and `bufnr` are provided.";
            default = "";
          };
          extraConfig = strOption "" "Extra config passed lsp setup function after `on_attach`";
        };
      });
      description = "Module for the ${name} (${package}) lsp server for nvim-lsp. Languages: ${server.languages}";
      default = null;
    };

  f = server: serverAttrs: toLspModule (helpers.fullAttrs server serverAttrs);
in mapAttrs f servers
