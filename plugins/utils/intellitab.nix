{ config, pkgs, lib, ... }:
with lib;
let

  name = "intellitab";

  cfg = config.programs.nixvim.plugins.${name};
  defs = import ../plugin-defs.nix { inherit pkgs; };
in
{
  options = {
    programs.nixvim.plugins.${name} = {
      enable = mkEnableOption "intellitab.nvim";
    };
  };

  config = mkIf cfg.enable {
    programs.nixvim = {
      extraPlugins = [ defs.intellitab-nvim ];

      maps.insert."<Tab>" = "<CMD>lua require([[intellitab]]).indent()<CR>";
      plugins.treesitter = {
        indent = true;
      };
    };
  };
}
