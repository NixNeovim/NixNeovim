{ pkgs, lib, helpers, config }:

with lib;

let

  name = "treesitter";
  pluginUrl = "https://github.com/nvim-treesitter/nvim-treesitter";

  cfg = config.programs.nixneovim.plugins.${name};

  inherit (helpers.custom_options)
    strOption
    boolOption
    boolOptionStrict;

  inherit (helpers.converter)
    flattenModuleOptions;

  keymapOption = default: mkOption {
    type = types.str;
    inherit default;
  };

  moduleOptions = {
    installAllGrammars = boolOptionStrict true "Install all grammars using nix (recommended, make sure no other grammars are installed)";

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

    # treesitter-refactor
    refactor = {
      highlightDefinitions = {
        enable = boolOption false "";
        # Set to false if you have an 'updatetime' of ~100.
        clearOnCursorMove = boolOption true "Set to false if you have an 'updatetime' of 100";
      };
      highlightCurrentScope = {
        enable = boolOption false "";
      };
      smartRename = {
        enable = boolOption false "Set to false if you have an 'updatetime' of ~100.";
        # Assign keymaps to false to disable them, e.g. 'smart_rename = false'.
        keymaps = {
          smartRename = strOption "grr" "Assign keymaps to false to disable them, e.g. 'smart_rename = false'.";
        };
      };
      navigation = {
        enable = boolOption false "Assign keymaps to false to disable them, e.g. 'smart_rename = false'.";
        # Assign keymaps to false to disable them, e.g. 'goto_definition = false'.
        keymaps = {
          gotoDefinition = strOption "gnd" "Assign keymaps to false to disable them, e.g. 'goto_definition = false'.";
          listDefinitions = strOption "gnD" "Assign keymaps to false to disable them, e.g. 'goto_definition = false'.";
          listDefinitionsToc = strOption "gO" "Assign keymaps to false to disable them, e.g. 'goto_definition = false'.";
          gotoNextUsage = strOption "<a-*>" "Assign keymaps to false to disable them, e.g. 'goto_definition = false'.";
          gotoPreviousUsage = strOption "<a-#>" "Assign keymaps to false to disable them, e.g. 'goto_definition = false'.";
        };
      };
    };
    contextCommentstring = {
      enable = boolOptionStrict false "Enable the nvim-ts-context-commentstring treesitter module";
    };
  };

  pluginOptions =
    let

      # This module has many options that cannot be mapped to the plugin options directly.
      # Therefore, some options are generated, and some are added manual.
      # Before combining them, we have to filter the generatedOptions.

      generatedOptions = flattenModuleOptions cfg moduleOptions;

      # options do not map 1-to-1 to the plugin options
      manualOptions = {
        highlight = { enable = cfg.enable; };
        indent = { enable = cfg.indent; };
      };

      # options that are generated but should not appear in the lua ouput
      optionsFilter = [
        "folding"
        "grammars"
        "excludeGrammars"
        "installAllGrammars"
      ];

      # apply the filter
      filteredGeneratedOptions =
        filterAttrs (k: v: ! elem k optionsFilter) generatedOptions;

    in recursiveUpdate filteredGeneratedOptions manualOptions;

  grammarsToInstall =
    let
      inherit (pkgs.vimPlugins.nvim-treesitter) allGrammars;

      combinedGrammars =
        cfg.grammars
        ++ optionals cfg.installAllGrammars allGrammars;
    in
      builtins.filter (x: ! elem x.name cfg.excludeGrammars) combinedGrammars;

in helpers.generator.mkLuaPlugin {
  inherit name moduleOptions pluginUrl;

  extraPlugins =
    let
      grammars = with pkgs;
        if grammarsToInstall != [] then
          [ (vimPlugins.nvim-treesitter.withPlugins (_: grammarsToInstall )) ]
        else
          [ vimPlugins.nvim-treesitter ];

      treesitterModules =
        optional cfg.contextCommentstring.enable pkgs.vimExtraPlugins.nvim-ts-context-commentstring;

    in grammars ++ treesitterModules;

  extraPackages = with pkgs; [
    # tree-sitter # only needed for :TSInstallFromGrammar (does not work on nix anyway)
    # nodejs # only needed for :TSInstallFromGrammar (does not work on nix anyway)
    gcc
    git
  ];

  extraOptions = mkIf (cfg.folding != null && cfg.folding) {
    foldmethod = "expr";
    foldexpr = "nvim_treesitter#foldexpr()";
  };

  extraConfigLua = ''
    require('nvim-treesitter.configs').setup(${helpers.converter.toLuaObject pluginOptions})
  '';

  defaultRequire = false;
}
