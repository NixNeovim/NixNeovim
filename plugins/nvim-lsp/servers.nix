{ pkgs, ... }:

# set of all available lsp server

with pkgs;

{
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
    packages = [];
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
  };
  ltex = {
    languages = "text files";
    packages = [ unstable.ltex-ls ];
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
    packages = [ cargo ];
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
}
