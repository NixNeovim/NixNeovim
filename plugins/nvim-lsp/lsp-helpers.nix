{ pkgs, config, lib, ... }:

with lib;
with types;
let
  helpers = (import ../helpers.nix { inherit lib config; });
in {

  # lsp-server-config = submodule {
  #   options = {
  #     name = mkOption {
  #       type = str;
  #       description = "The server's name";
  #     };
  #     extraOptions = mkOption {
  #       type = attrs;
  #       description = "Extra options for the server";
  #     };
  #   };
  # };


  # create the lua code to activate the lsp server
  serverToLua = servers: setupWrappers:
    mapAttrsToList (serverName: _options:
      let

        ## add wrapper functions to lua lsp config
        runWrappers = wrappers: s:
          if wrappers == [] then s
          else (head wrappers) (runWrappers (tail wrappers) s);

        onAttach =
          ''
          local __on_attach = function(client, bufnr)
            ${servers.${serverName}.onAttachExtra}
          end
        '';

        wrapped-setup = "local __setup = ${runWrappers setupWrappers "{
          on_attach = __on_attach,
          ${servers.${serverName}.extraConfig}
        }"}";

      in if isNull servers.${serverName} then ""
        else if servers.${serverName}.enable then
        ''
          do -- lsp server config ${serverName}
            ${onAttach}
            ${wrapped-setup}
            require('lspconfig')["${serverName}"].setup(__setup)
          end -- lsp server config ${serverName}
        ''
        else "") servers;

  # list of all available lsp server
  servers = [
    {
      name = "clangd";
      description = "Enable clangd LSP, for C/C++.";
      packages = [ pkgs.clang-tools ];
    }
    {
      name = "cssls";
      description = "Enable cssls, for CSS";
      packages = [ pkgs.nodePackages.vscode-langservers-extracted ];
    }
    {
      name = "eslint";
      description = "Enable eslint";
      packages = [ pkgs.nodePackages.vscode-langservers-extracted ];
    }
    {
      name = "gdscript";
      description = "Enable gdscript, for Godot";
      packages = [];
    }
    {
      name = "gopls";
      description = "Enable gopls, for Go.";
    }
    {
      name = "hls";
      description = "Enable hls language server for Haskell";
      packages = [ pkgs.haskell-language-server ];
    }
    {
      name = "html";
      description = "Enable html, for HTML";
      packages = [ pkgs.nodePackages.vscode-langservers-extracted ];
    }
    {
      name = "jsonls";
      description = "Enable jsonls, for JSON";
      packages = [ pkgs.nodePackages.vscode-langservers-extracted ];
    }
    {
      name = "ltex";
      description = "Enable ltex-ls, for text files.";
      packages = [ pkgs.unstable.ltex-ls ];
    }
    {
      name = "pyright";
      description = "Enable pyright, for Python.";
    }
    {
      name = "rnix-lsp";
      description = "Enable rnix LSP, for Nix";
      serverName = "rnix";
    }
    {
      name = "rust-analyzer";
      description = "Enable rust-analyzer, for Rust.";
      serverName = "rust_analyzer";
      packages = [ pkgs.cargo ];
    }
    {
      name = "texlab";
      description = "Enable texlab, for latex.";
    }
    {
      name = "vuels";
      description = "Enable vuels, for Vue";
      packages = [ pkgs.nodePackages.vue-language-server ];
    }
    {
      name = "zls";
      description = "Enable zls, for Zig.";
    }
  ];

  # mkLsp = { name
  #   , description ? "Enable ${name}."
  #   , serverName ? name
  #   , packages ? [ pkgs.${name} ]
  #   , ... }:

  #     # returns a module
  #     { pkgs, config, lib, ... }:
  #       let
  #         cfg = config.programs.nixvim.plugins.lsp.servers.${name};
  #       in
  #       {
  #         options = {
  #           programs.nixvim.plugins.lsp.servers.${name} = {
  #             enable = mkEnableOption description;
  #           };
  #         };

  #         config = mkIf cfg.enable {
  #           programs.nixvim.extraPackages = packages;

  #           programs.nixvim.plugins.lsp.enabledServers = [ serverName ];
  #         };
  #       };
}
