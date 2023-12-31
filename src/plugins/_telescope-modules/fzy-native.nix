{ pkgs, config, lib }:
with lib;
let
  cfg = config.programs.nixneovim.plugins.telescope.extensions.fzy-native;
in
{
  options.programs.nixneovim.plugins.telescope.extensions.fzy-native = {
    enable = mkEnableOption "fzy-native";

    overrideGenericSorter = mkOption {
      type = types.nullOr types.bool;
      description = "Override the generice sorter";
      default = null;
    };
    overrideFileSorter = mkOption {
      type = types.nullOr types.bool;
      description = "Override the file sorter";
      default = null;
    };
  };

  config =
    let
      configuration = {
        override_generic_sorter = cfg.overrideGenericSorter;
        override_file_sorter = cfg.overrideFileSorter;
      };
    in
    mkIf cfg.enable {
      programs.nixneovim.extraPlugins = [ pkgs.vimPlugins.telescope-fzy-native-nvim ];

      programs.nixneovim.plugins.telescope.enabledExtensions = [ "fzy_native" ];
      programs.nixneovim.plugins.telescope.extensionConfig."fzy_native" = configuration;
    };
}
