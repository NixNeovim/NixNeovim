{ pkgs, lib, config, ... }:

with lib;

let

  name = "treesitter";
  plugin-url = "https://github.com/nvim-treesitter/nvim-treesitter";

  helpers = import ../helpers.nix { inherit lib config; };
  cfg = config.programs.nixvim.plugins.${name};

  keymapOption = default: mkOption {
    type = types.str;
    inherit default;
  };

  moduleOptions = with helpers; {
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
with helpers;
mkLuaPlugin {
  inherit name moduleOptions;
  description = "Enable ${name}.nvim (${plugin-url})";

  extraPlugins = with pkgs;
    if cfg.installAllGrammars then
      [ unstable.vimPlugins.nvim-treesitter.withAllGrammars ]
    else
      [ unstable.vimPlugins.nvim-treesitter ];

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
}
