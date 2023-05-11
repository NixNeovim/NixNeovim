{ pkgs, lib, config, ... }:

with lib;

let

  name = "treesitter";
  pluginUrl = "https://github.com/nvim-treesitter/nvim-treesitter";

  helpers = import ../../helper { inherit pkgs lib config; };
  cfg = config.programs.nixneovim.plugins.${name};

  inherit (helpers.customOptions) boolOption;

  keymapOption = default: mkOption {
    type = types.str;
    inherit default;
  };

  moduleOptions = {
    installAllGrammars = boolOption true "Install all grammars using nix (recommended, make sure no other grammars are installed)";

    indent = boolOption false "Enable tree-sitter based indentation (This is the equivalent to indent { enable = true } in the original lua config)";
    folding = boolOption false "Enable tree-sitter based folding";

    grammars = mkOption {
      type = types.listOf types.package;
      default = [];
    };
    excludeGrammars = mkOption {
      default = [];
    };

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

  grammarsToInstall =
    let
      inherit (pkgs.vimPlugins.nvim-treesitter) allGrammars;

      combinedGrammars =
        cfg.grammars
        ++ optionals cfg.installAllGrammars allGrammars;
    in
      builtins.filter (x: ! elem x.name cfg.excludeGrammars) combinedGrammars;

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;

  extraPlugins = with pkgs;
    if grammarsToInstall != [] then
      [ (vimPlugins.nvim-treesitter.withPlugins (_: grammarsToInstall )) ]
    else
      [ vimPlugins.nvim-treesitter ];

  extraPackages = with pkgs; [
    tree-sitter
    nodejs
  ];

  extraOptions = mkIf cfg.folding {
    foldmethod = "expr";
    foldexpr = "nvim_treesitter#foldexpr()";
  };

  extraConfigLua = ''
    require('nvim-treesitter.configs').setup(${helpers.toLuaObject pluginOptions})
  '';

  defaultRequire = false;
}
