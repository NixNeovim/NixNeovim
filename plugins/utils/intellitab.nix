{ config, pkgs, lib, root }:
with lib;
let

  name = "intellitab";

  cfg = config.programs.nixneovim.plugins.${name};
  defs = root.deprecated.plugin-defs;
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

      mappings.insert."<Tab>" = "'<CMD>lua require([[intellitab]]).indent()<CR>'";
      plugins.treesitter = {
        indent = true;
      };
    };
  };
}
