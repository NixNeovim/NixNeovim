{ pkgs, config, lib }:
with lib;
let
  cfg = config.programs.nixneovim.colorschemes.one;
in
{
  options = {
    programs.nixneovim.colorschemes.one = {
      enable = mkEnableOption "vim-one";
    };
  };

  config = mkIf cfg.enable {
    programs.nixneovim = {
      colorscheme = "one";
      extraPlugins = [ pkgs.vimPlugins.vim-one ];

      options = {
        termguicolors = true;
      };
    };
  };
}
