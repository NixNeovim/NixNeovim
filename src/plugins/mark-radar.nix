{ pkgs, lib, helpers, root, config }:

with lib;
let
  cfg = config.programs.nixneovim.plugins.mark-radar;
  defs = root.deprecated.plugin-defs;
in
{
  options.programs.nixneovim.plugins.mark-radar = {
    enable = mkEnableOption "mark-radar";

    highlight_background = mkOption {
      type = with types; nullOr bool;
      default = null;
    };

    background_highlight_group = mkOption {
      type = with types; nullOr str;
      default = null;
    };

    highlight_group = mkOption {
      type = with types; nullOr str;
      default = null;
    };

    set_default_keybinds = mkOption {
      type = with types; nullOr str;
      default = null;
    };
  };

  config =
    let
      opts = helpers.converter.toLuaObject {
        inherit (cfg) highlight_group background_highlight_group;
        set_default_mappings = cfg.set_default_keybinds;
        background_highlight = cfg.highlight_background;
      };
    in
    mkIf cfg.enable {
      programs.nixneovim = {
        extraPlugins = [ defs.mark-radar ];

        extraConfigLua = ''
          require("mark-radar").setup(${opts})
        '';
      };
    };
}
