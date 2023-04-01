{ config, pkgs, lib, ... }:
with lib;
let

  name = "tabby";

  cfg = config.programs.nixneovim.plugins.${name};
  helpers = import ../../helper { inherit pkgs lib config; };
  inherit (helpers.customOptions) boolOption;

  highlight = mkOption {
    type = types.nullOr (types.submodule ({ ... }: {
      options = {
        guifg = mkOption {
          type = types.nullOr types.str;
          description = "foreground color";
          default = null;
        };
        guibg = mkOption {
          type = types.nullOr types.str;
          description = "background color";
          default = null;
        };
      };
    }));
    default = null;
  };
in {
  options = {
    programs.nixneovim.plugins.${name} = {
      enable = mkEnableOption "Enable ${name}";

      presets = {
        activeWinsAtTall = boolOption false "";
        activeWinsAtEnd = boolOption false "";
        tabWithTopWin = boolOption false "";
        activeTabWithWins = boolOption false "";
        tabOnly = boolOption false "";
      };
    };
  };

  config =
    let
      setupOptions = {
        options = {
          # presets = {
          #   active_wins_at_tall = cfg.presets.activeWinsAtTall;
          # };
        };
      };
    in
    mkIf cfg.enable {
      programs.nixneovim = {
        extraPlugins = with pkgs.vimExtraPlugins; [
          tabby-nvim
        ];
        extraConfigLua = ''
          require('tabby').setup${helpers.toLuaObject setupOptions}
        '';
      };
    };
}
