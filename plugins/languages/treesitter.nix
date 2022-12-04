{ pkgs, lib, config, ... }:

with lib;

let

  cfg = config.programs.nixvim.plugins.treesitter;
  helpers = import ../helpers.nix { inherit lib config; };

  keymapOption = default: mkOption {
    type = types.str;
    inherit default;
  };

in
with helpers;
{
  options = {
    programs.nixvim.plugins.treesitter = {
      enable = mkEnableOption "Enable tree-sitter syntax highlighting";

      installAllGrammars = boolOption true "Install all grammars using nix (recommended, make sure no other grammars are installed)";

      indent = boolOption false "Enable tree-sitter based indentation (This is the equivalent to indent { enable = true } in the original lua config)";
      folding = boolOption false "Enable tree-sitter based folding";

      incrementalSelection = {
        enable = mkEnableOption "Incremental selection based on the named nodes from the grammar";
        keymaps = {
            initSelection = keymapOption "gnn";
            nodeIncremental = keymapOption "grn";
            scopeIncremental = keymapOption "grc";
            nodeDecremental = keymapOption "grm";
          };
      };
    };
  };

  config =
    let
      pluginOptions = {
        highlight = { enable = cfg.enable; };
        indent = { enable = cfg.indent; };

        incremental_selection = {
          enable = cfg.incrementalSelection.enable;
          keymaps = with cfg.incrementalSelection.keymaps; {
            init_selection = initSelection;
            node_incremental = nodeIncremental;
            scope_incremental = scopeIncremental;
            node_decremental = nodeDecremental;
          };
        };

      };

    in
    mkIf cfg.enable {
      programs.nixvim = {
        extraConfigLua = ''
            require('nvim-treesitter.configs').setup(${helpers.toLuaObject pluginOptions})
          '';

        extraPlugins = with pkgs;
          if cfg.installAllGrammars then
            [ unstable.vimPlugins.nvim-treesitter.withAllGrammars ]
          else
            [ unstable.vimPlugins.nvim-treesitter ];

        extraPackages = [ pkgs.tree-sitter pkgs.nodejs ];

        options = mkIf cfg.folding {
          foldmethod = "expr";
          foldexpr = "nvim_treesitter#foldexpr()";
        };
      };
    };
}
