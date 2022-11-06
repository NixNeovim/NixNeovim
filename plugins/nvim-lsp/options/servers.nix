{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with types; let
  helpers = import ../../helpers.nix {inherit lib config;};

  mkServerOption = server: attr:
    mkOption {
      type = submodule {
        options = with helpers; {
          enable = mkEnableOption "";
          onAttachExtra = mkOption {
            type = types.lines;
            description = "A lua function to be run when ${server.name} is attached. The argument `client` and `bufnr` are provided.";
            default = "";
          };
          extraConfig =
            strOption ""
            "Extra config passed lsp setup function after `on_attach`";
        };
      };
      description = "Module for the ${name} (${attr.package}) lsp server for nvim-lsp. Languages: ${server.languages}";
      default = {};
    };

  serversSet = {
    clangd = {
      languages = "C, C++";
      packages = [clang-tools];
    };
    cssls = {
      languages = "CSS";
      packages = [nodePackages.vscode-langservers-extracted];
    };
    eslint = {
      languages = "eslint";
      packages = [nodePackages.vscode-langservers-extracted];
    };
    gdscript = {
      languages = "Godot";
      packages = [];
    };
    gopls = {languages = "Go";};
    hls = {
      languages = "Haskell";
      packages = [haskell-language-server ghc];
    };
    html = {
      languages = "HTML";
      packages = [nodePackages.vscode-langservers-extracted];
    };
    jsonls = {
      languages = "JSON";
      packages = [nodePackages.vscode-langservers-extracted];
    };
    kotlin-language-server = {
      languages = "Kotlin";
      packages = [pkgs.kotlin-language-server];
      serverName = "kotlin_language_server";
    };
    ltex = {
      languages = "text files";
      packages = [unstable.ltex-ls];
    };
    pyright = {languages = "Python";};
    rnix-lsp = {
      languages = "Nix";
      packages = [rnix-lsp];
      serverName = "rnix";
    };
    rust-analyzer = {
      languages = "Rust";
      serverName = "rust_analyzer";
      packages = [cargo];
    };
    texlab = {languages = "latex";};
    vuels = {
      languages = "Vue";
      packages = [nodePackages.vue-language-server];
    };
    zls = {languages = "Zig";};
  };

  # fill out missing information to language server definition
  fillMissingInfo = name: {
    languages ? "unspecified",
    packages ? [pkgs.vimExtraPlugins.${name}],
    serverName ? name,
  }: {
    inherit languages packages serverName;
  };

  servers = mapAttrs fillMissingInfo serversSet;

  # filter only activated servers
  activated = cfg-servers:
    filterAttrs (name: attrs: cfg-servers.${name}.enable) servers;
in {
  # create nix Option for all servers
  options = mapAttrs mkServerOption servers;

  inherit activated;

  packages = cfg-servers: let
    lists =
      mapAttrsToList (name: attrs: attrs.packages) (activated cfg-servers);
  in
    flatten lists; # # return packages of activated sources
}
