{ pkgs, config, lib, super }:
with lib;
let
  cfg = config.programs.nixneovim.colorschemes.base16;
  themes = super.base16-list;
in
{
  options = {
    programs.nixneovim.colorschemes.base16 = {
      enable = mkEnableOption "base16";

      useTruecolor = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to use truecolor for the colorschemes. If set to false, you'll need to set up base16 in your shell.";
      };

      colorscheme = mkOption {
        type = types.enum themes;
        description = "The base16 colorscheme to use";
        default = "default-dark";
      };

      setUpBar = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to install the matching plugin for your statusbar. This does nothing as of yet, waiting for upstream support.";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.nixneovim = {
      colorscheme = "base16-${cfg.colorscheme}";
      extraPlugins = [ pkgs.vimPlugins.base16-vim ];

      plugins.airline.theme = mkIf (cfg.setUpBar) "base16";
      plugins.lightline.colorscheme = null;

      options.termguicolors = mkIf cfg.useTruecolor true;
    };
  };
}
