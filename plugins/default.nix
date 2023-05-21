{ pkgs, lib, config, ... }:

with builtins;

let
  filesIn = path:
    let content = attrNames (readDir (./. + "/${path}"));
    in map (x: ./. + "/${path}/${x}") content;

  utils = filesIn "utils";
  completion = filesIn "completion";
  bufferlines = filesIn "bufferlines";
  git = filesIn "git";

  helpers = import ../helper { inherit pkgs lib config; };
in
{
  _module.args = {
    helpers = helpers;
  };

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
    ./colorschemes/rose-pine.nix
    ./colorschemes/tokyonight.nix
    ./colorschemes/gruvbox-baby.nix
    ./colorschemes/gruvbox-material.nix

    ./debugging/nvim-dap
    ./debugging/nvim-dap-ui.nix

    ./languages/ledger.nix
    ./languages/nix.nix
    ./languages/zig.nix
    ./languages/rust.nix

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
