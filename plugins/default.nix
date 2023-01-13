with builtins;

let
  # filesIn = path-name: path: # TODO: this should be possible with only one argument
  filesIn = path:
    let content = attrNames (readDir (./. + "/${path}"));
    in map (x: ./. + "/${path}/${x}") content;

  utils = filesIn "utils";
  completion = filesIn "completion";
  bufferlines = filesIn "bufferlines";
  git = filesIn "git";
in
{
  imports =
    utils ++
    completion ++
    bufferlines ++
    git ++
    [
    ./generated.nix

    ./colorschemes/base16.nix
    ./colorschemes/gruvbox.nix
    ./colorschemes/nord.nix
    ./colorschemes/one.nix
    ./colorschemes/onedark.nix
    ./colorschemes/tokyonight.nix

    ./debugging/nvim-dap
    ./debugging/nvim-dap-ui.nix

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
  ];
}
