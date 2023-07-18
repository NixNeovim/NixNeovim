{ lib, config, pkgs, ... }:

with lib;
with types;
with pkgs;

let

  helpers = import ../../../helper { inherit pkgs lib config; };
  inherit (helpers.customOptions) strOption;

  mkServerOption = server: attr:
    mkOption {
      type = submodule {
        options = {
          enable = mkEnableOption "";
          onAttachExtra = mkOption {
            type = types.lines;
            description = "A lua function to be run when ${server} is attached. The argument `client` and `bufnr` are provided.";
            default = "";
          };
          extraConfig = strOption "" "Extra config passed lsp setup function after `on_attach`";
        };
      };
      description = "Module for the ${server} (${toString attr.packages}) lsp server for nvim-lsp. Languages: ${toString attr.languages}";
      default = { };
    };

  # Posible fields are:
  # - languages: Used in the docs
  # - packages: used if the name of the nix packages differs from the key
  # - serverName: name of the server as called in `lspconfig.<serverName>.setup()
  serversSet = {
    bashls = {
      languages = "Bash";
      packages = [ nodePackages.bash-language-server ];
    };
    clangd = {
      languages = "C, C++";
      packages = [ clang-tools ];
    };
    cssls = {
      languages = "CSS";
      packages = [ nodePackages.vscode-langservers-extracted ];
    };
    eslint = {
      languages = "eslint";
      packages = [ nodePackages.vscode-langservers-extracted ];
    };
    gdscript = {
      languages = "Godot";
      packages = [ ];
    };
    gopls = {
      languages = "Go";
    };
    hls = {
      languages = "Haskell";
      packages = [ haskell-language-server ghc ];
    };
    html = {
      languages = "HTML";
      packages = [ nodePackages.vscode-langservers-extracted ];
    };
    jsonls = {
      languages = "JSON";
      packages = [ nodePackages.vscode-langservers-extracted ];
    };
    kotlin-language-server = {
      languages = "Kotlin";
      packages = [ pkgs.kotlin-language-server ];
      serverName = "kotlin_language_server";
    };
    ltex = {
      languages = "text files";
      packages = [ ltex-ls ];
    };
    lua-language-server = {
      languages = "Lua";
      packages = [ pkgs.lua-language-server ];
    };
    nil = {
      languages = "Nix";
      serverName = "nil_ls";
    };
    pyright = {
      languages = "Python";
    };
    rnix-lsp = {
      languages = "Nix";
      packages = [ rnix-lsp ];
      serverName = "rnix";
    };
    rust-analyzer = {
      languages = "Rust";
      serverName = "rust_analyzer";
      packages = [ cargo rust-analyzer ];
    };
    terraform-ls = {
      languages = "HCL";
      serverName = "terraformls";
    };
    texlab = {
      languages = "latex";
    };
    vuels = {
      languages = "Vue";
      packages = [ nodePackages.vue-language-server ];
    };
    zls = {
      languages = "Zig";
    };
  };

  # fill out missing information to language server definition
  fillMissingInfo = name: { languages ? "unspecified"
                          , packages ? [ pkgs.${name} ]
                          , serverName ? name
                          }: { inherit languages packages serverName; };


  servers = mapAttrs fillMissingInfo serversSet;

  # filter only activated servers
  activated = cfg-servers: filterAttrs (name: attrs: cfg-servers.${name}.enable) servers;

in
{

  # create nix Option for all servers
  options = mapAttrs mkServerOption servers;

  activated = activated;

  # input:
  # - config.programs.nixneovim.plugins.lsp.servers
  # output:
  # - all required packages
  packages = cfg-servers:
    let
      lists = mapAttrsToList (name: attrs: attrs.packages) (activated cfg-servers);
    in
    flatten lists; ## return packages of activated sources

}
