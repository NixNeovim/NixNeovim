with builtins;

let
  filesIn = path:
    let content = attrNames (readDir path);
    in map (x: ./. + "/utils/${x}") content;

  utils = filesIn ./utils;
in
{
  imports = [
    ./generated.nix

    ./bufferlines/barbar.nix
    ./bufferlines/bufferline.nix
    ./bufferlines/tabby.nix

    ./colorschemes/base16.nix
    ./colorschemes/gruvbox.nix
    ./colorschemes/nord.nix
    ./colorschemes/one.nix
    ./colorschemes/onedark.nix
    ./colorschemes/tokyonight.nix

    ./completion/coq.nix
    ./completion/nvim-cmp

    ./debugging/nvim-dap
    ./debugging/nvim-dap-ui.nix

    ./git/fugitive.nix
    ./git/gitgutter.nix
    ./git/neogit.nix

    ./languages/ledger.nix
    ./languages/nix.nix
    ./languages/zig.nix

    ./mini

    ./null-ls

    ./nvim-lsp

    ./pluginmanagers/packer.nix

    ./statuslines/airline.nix
    ./statuslines/lightline.nix
    ./statuslines/lualine.nix

    ./telescope
  ] ++ utils;
}
