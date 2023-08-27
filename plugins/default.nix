{ pkgs, lib, config, helpers, ... }:

with builtins;

let

  filesIn = path:
    let content = attrNames (readDir (./. + "/${path}"));
    in map (x: ./. + "/${path}/${x}") content;

  utils = filesIn "utils";
  completion = filesIn "completion";
  bufferlines = filesIn "bufferlines";
  git = filesIn "git";

  plugin-files = # utils ++
    completion ++
    bufferlines ++
    git ++
    [
    ./utils/bamboo.nix
    ./utils/bufdelete.nix
    ./utils/colorizer.nix
    ./utils/commentary.nix
    ./utils/comment-frame.nix
    ./utils/comment.nix
    ./utils/dashboard.nix
    ./utils/diffview.nix
    ./utils/easyescape.nix
    ./utils/emmet.nix
    ./utils/endwise.nix
    ./utils/floaterm.nix
    ./utils/focus.nix
    ./utils/ghosttext.nix
    ./utils/goyo.nix
    ./utils/hbac.nix
    ./utils/headlines.nix
    ./utils/incline.nix
    ./utils/indent-blankline.nix
    ./utils/intellitab.nix
    ./utils/lspkind.nix
    ./utils/lsp-lines.nix
    ./utils/lsp-progress.nix
    ./utils/lspsaga.nix
    ./utils/luasnip.nix
    ./utils/markdown-preview.nix
    ./utils/mark-radar.nix
    ./utils/nerdcommenter.nix
    ./utils/notify.nix
    ./utils/numb.nix
    ./utils/nvim-autopairs.nix
    ./utils/nvim-jqx.nix
    ./utils/nvim-lightbulb.nix
    ./utils/nvim-toggler.nix
    ./utils/nvim-tree.nix
    ./utils/oil.nix
    ./utils/plantuml-syntax.nix
    ./utils/project-nvim.nix
    ./utils/scrollbar.nix
    ./utils/snippy.nix
    ./utils/specs.nix
    ./utils/stabilize.nix
    ./utils/startify.nix
    ./utils/surround.nix
    ./utils/tagbar.nix
    ./utils/todo-comments.nix
    ./utils/treesitter-context.nix
    ./utils/treesitter.nix
    ./utils/trouble.nix
    ./utils/ts-context-commentstring.nix
    ./utils/undotree.nix
    ./utils/vimtex.nix
    ./utils/vimwiki.nix
    ./utils/which-key.nix
    ./utils/windows.nix
    ./utils/zk.nix

    # ./generated.nix

    # ./colorschemes/base16.nix
    # ./colorschemes/gruvbox.nix
    # ./colorschemes/nord.nix
    # ./colorschemes/one.nix
    # ./colorschemes/onedark.nix
    # ./colorschemes/rose-pine.nix
    # ./colorschemes/tokyonight.nix
    # ./colorschemes/gruvbox-baby.nix
    # ./colorschemes/gruvbox-material.nix
    # ./colorschemes/kanagawa.nix

    # ./debugging/nvim-dap
    # ./debugging/nvim-dap-ui.nix

    # ./languages/ledger.nix
    # ./languages/nix.nix
    # ./languages/zig.nix
    # ./languages/rust.nix

    # ./mini

    # ./null-ls

    # ./nvim-lsp

    # ./pluginmanagers/packer.nix

    # ./statuslines/airline.nix
    # ./statuslines/lightline.nix
    # ./statuslines/lualine.nix
    # ./utils/windows.nix

    # ./telescope
    ];

  # creates list of all imports
  plugins-config =
    let
      f = path: import "${path}" { inherit config lib pkgs helpers; };
    in builtins.map f plugin-files;

  pluginOptions =
    let
      f = path: (import "${path}" { inherit config lib pkgs helpers; }).options;
    in builtins.map f plugin-files;

in {

  imports = plugins-config;

  plugins = pluginOptions;
}
