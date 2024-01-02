{ pkgs, config, lib }:
with lib;
let
  cfg = config.programs.nixneovim.colorschemes.onedark;
in
{
  options = {
    programs.nixneovim.colorschemes.onedark = {
      enable = mkEnableOption "onedark";
    };
  };

  config = mkIf cfg.enable {
    programs.nixneovim = {
      colorscheme = "onedark";
      extraPlugins = [ pkgs.vimPlugins.onedark-vim ];

      options = {
        termguicolors = true;
      };
    };
  };
}
