{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.programs.nixvim.plugins.lsp;
  helpers = (import ../helpers.nix { inherit lib config; });
  lsp-helpers = (import ./lsp-helpers.nix { inherit lib config pkgs; });
in {

  options.programs.nixvim.plugins.lsp = {
    enable = mkEnableOption "Enable neovim's built-in LSP";

    servers = import ./options/servers.nix { inherit lib config pkgs; };

    onAttach = mkOption {
      type = types.lines;
      description = "A lua function to be run when a new LSP buffer is attached. The argument `client` is provided.";
      default = "";
    };

    setupWrappers = mkOption {
      type = with types; listOf (functionTo str);
      description = "Code to be run to wrap the setup args. Takes in an argument containing the previous results, and returns a new string of code.";
      default = [];
    };

    preConfig = mkOption {
      type = types.lines;
      description = "Code to be run before loading the LSP. Useful for requiring plugins";
      default = "";
    };
  };

  config = let

    extraPackages = lsp-helpers.lspPackages cfg.servers;

  in mkIf cfg.enable {
    programs.nixvim = {

      inherit extraPackages;

      extraPlugins = [ pkgs.vimPlugins.nvim-lspconfig ];

      extraConfigLua =
        let
          activatedServer = lsp-helpers.serversToLua cfg.servers cfg.setupWrappers; # create lua code for lsp server, with setup wrapper
        in ''
          do -- LSP
            ${cfg.preConfig}
            ${concatStringsSep "\n" activatedServer}
          end -- END LSP
        '';
    };
  };
}
          # for i,server in ipairs(__lspServers) do
          #   if type(server) == "string" then
          #     require('lspconfig')[server].setup(__setup)
          #   else
          #     local options = ${runWrappers cfg.setupWrappers "server.extraOptions"}
          #     require('lspconfig')[server.name].setup(options)
          #   end
          # end

            # local __lspOnAttach = function(client)
            #   ${cfg.onAttach}
            # end
