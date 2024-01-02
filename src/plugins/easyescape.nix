{ config, pkgs, lib }:
with lib;
let
  cfg = config.programs.nixneovim.plugins.easyescape;
in
{
  options = {
    programs.nixneovim.plugins.easyescape = {
      enable = mkEnableOption "easyescape";
    };
  };
  config = mkIf cfg.enable {
    programs.nixneovim = {
      extraPlugins = with pkgs.vimPlugins; [
        vim-easyescape
      ];
    };
  };
}
