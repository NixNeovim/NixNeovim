{ pkgs, ... }:

# set of all available lsp server

{
    clangd = {
      languages = "C, C++";
      packages = [ pkgs.clang-tools ];
    };
    cssls = {
      languages = "CSS";
      packages = [ pkgs.nodePackages.vscode-langservers-extracted ];
    };
    eslint = {
      languages = "eslint";
      packages = [ pkgs.nodePackages.vscode-langservers-extracted ];
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
      packages = [ pkgs.haskell-language-server ];
    };
    html = {
      languages = "HTML";
      packages = [ pkgs.nodePackages.vscode-langservers-extracted ];
    };
    jsonls = {
      languages = "JSON";
      packages = [ pkgs.nodePackages.vscode-langservers-extracted ];
    };
    ltex = {
      languages = "text files";
      packages = [ pkgs.unstable.ltex-ls ];
    };
    pyright = {
      languages = "Python";
    };
    rnix-lsp = {
      languages = "Nix";
      packages = [ pkgs.rnix-lsp ];
      serverName = "rnix";
    };
    rust-analyzer = {
      languages = "Rust";
      serverName = "rust_analyzer";
      packages = [ pkgs.cargo ];
    };
    texlab = {
      languages = "latex";
    };
    vuels = {
      languages = "Vue";
      packages = [ pkgs.nodePackages.vue-language-server ];
    };
    zls = {
      languages = "Zig";
    };
  }
