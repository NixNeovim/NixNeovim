{ pkgs, config, lib }:
with lib;
let
  cfg = config.programs.nixneovim.plugins.commentary;
in
{
  # TODO Add support for aditional filetypes. This requires autocommands!

  options = {
    programs.nixneovim.plugins.commentary = {
      enable = mkEnableOption "commentary";
    };
  };

  config = mkIf cfg.enable {
    programs.nixneovim = {
      extraPlugins = [ pkgs.vimPlugins.vim-commentary ];
    };
  };
}
