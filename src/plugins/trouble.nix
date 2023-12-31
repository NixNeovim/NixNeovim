{ config, lib, pkgs, helpers }:
with lib;
let
  cfg = config.programs.nixneovim.plugins.trouble;
in
{
  options = {
    programs.nixneovim.plugins.trouble = {
      enable = mkEnableOption "trouble.nvim";

      position = mkOption {
        description = "position of the list";
        type = types.enum [ "bottom" "top" "left" "right" ];
        default = "bottom";
      };

      # TODO: other options from https://github.com/folke/trouble.nvim

    };
  };

  config =
    let
      options = {
        position = cfg.position;
      };

      filteredOptions = filterAttrs (_: v: !isNull v) options;
    in
    mkIf cfg.enable {
      programs.nixneovim = {
        extraPlugins = [ pkgs.vimPlugins.trouble-nvim ];
        extraConfigLua = ''
          require("trouble").setup${helpers.converter.toLuaObject filteredOptions}
        '';
      };
    };
}
