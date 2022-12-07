{ config, pkgs, lib, ... }:
with lib;
let

  name = "intellitab";

  cfg = config.programs.nixneovim.plugins.${name};
  defs = import ../plugin-defs.nix { inherit pkgs; };
in
{
  options = {
    programs.nixneovim.plugins.${name} = {
      enable = mkEnableOption "intellitab.nvim";
    };
  };

  config = mkIf cfg.enable {
    programs.nixneovim = {
      extraPlugins = [ defs.intellitab-nvim ];

      maps.insert."<Tab>" = "<CMD>lua require([[intellitab]]).indent()<CR>";
      plugins.treesitter = {
        indent = true;
      };
    };
  };
}
