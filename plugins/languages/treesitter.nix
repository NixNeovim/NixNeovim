{ pkgs, lib, config, ... }:

with lib;

let

  cfg = config.programs.nixvim.plugins.treesitter;
  helpers = import ../helpers.nix { inherit lib config; };

in
with helpers;
{
  options = {
    programs.nixvim.plugins.treesitter = {
      enable = mkEnableOption "Enable tree-sitter syntax highlighting";

      installAllGrammars = boolOption true "Install all grammars using nix (recommended)";

      # parserInstallDir = mkOption {
      #   type = types.nullOr types.str;
      #   default = null;
      #   description = "Location of the parsers to be installed by the plugin (only needed when nixGrammars is disabled)";
      # };

      # ignoreInstall = mkOption {
      #   type = types.listOf types.str;
      #   default = [ ];
      #   description = "List of parsers to ignore installing (for \"all\")";
      # };

      # disabledLanguages = mkOption {
      #   type = types.listOf types.str;
      #   default = [ ];
      #   description = "A list of languages to disable";
      # };

      customCaptures = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description = "Custom capture group highlighting";
      };

      incrementalSelection =
        let
          keymap = default: mkOption {
            type = types.str;
            inherit default;
          };
        in
        {
          enable = mkEnableOption "Incremental selection based on the named nodes from the grammar";
          keymaps = {
            initSelection = keymap "gnn";
            nodeIncremental = keymap "grn";
            scopeIncremental = keymap "grc";
            nodeDecremental = keymap "grm";
          };
        };

      indent = boolOption false "Enable tree-sitter based indentation (This is the equivalent to indent { enable = true } in the original lua config)";
      folding = boolOption false "Enable tree-sitter based folding";
      # syncInstall = boolOption false "Do not install languages asyncroniously";
      # autoInstall = boolOption true "Install languages automatically";
    };
  };

  config =
    let
      pluginOptions = {
        highlight = {
          enable = cfg.enable;
          # disable = if (cfg.disabledLanguages != [ ]) then cfg.disabledLanguages else null;

          custom_captures = if (cfg.customCaptures != { }) then cfg.customCaptures else null;
        };

        incremental_selection =
          if cfg.incrementalSelection.enable then {
            enable = true;
            keymaps = {
              init_selection = cfg.incrementalSelection.keymaps.initSelection;
              node_incremental = cfg.incrementalSelection.keymaps.nodeIncremental;
              scope_incremental = cfg.incrementalSelection.keymaps.scopeIncremental;
              node_decremental = cfg.incrementalSelection.keymaps.nodeDecremental;
            };
          } else null;

        indent =
          if cfg.indent then {
            enable = true;
          } else null;

        # ensure_installed = if cfg.nixGrammars then [ ] else cfg.ensureInstalled;
        # ignore_install = cfg.ignoreInstall;
        # parser_install_dir = cfg.parserInstallDir;
      };

      incremental_selection =
        if cfg.incrementalSelection.enable then
          {
            enable = true;
            keymaps = {
              init_selection = cfg.incrementalSelection.keymaps.initSelection;
              node_incremental = cfg.incrementalSelection.keymaps.nodeIncremental;
              scope_incremental = cfg.incrementalSelection.keymaps.scopeIncremental;
              node_decremental = cfg.incrementalSelection.keymaps.nodeDecremental;
            };
          }
        else null;

      indent =
        if cfg.indent then
          { enable = true; }
        else null;

      # ensure_installed = cfg.ensureInstalled;
      # sync_install = cfg.syncInstall;
      # auto_install = cfg.autoInstall;

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
