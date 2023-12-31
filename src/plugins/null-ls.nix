{ pkgs, lib, helpers, super, config }:
with lib;
let
  cfg = config.programs.nixneovim.plugins.null-ls;
in
{
  imports = [
    # ./servers.nix
    super.null-ls-modules.servers
  ];

  options.programs.nixneovim.plugins.null-ls = {
    enable = mkEnableOption "null-ls";

    debug = mkOption {
      default = null;
      type = with types; nullOr bool;
    };

    sourcesItems = mkOption {
      default = null;
      # type = with types; nullOr (either (listOf str) (listOf attrsOf str));
      type = with types; nullOr (listOf (attrsOf str));
      description = "The list of sources to enable, should be strings of lua code. Don't use this directly";
    };

    # sources = mkOption {
    #   default = null;
    #   type = with types; nullOr attrs;
    # };
  };

  config =
    let
      options = {
        debug = cfg.debug;
        sources = cfg.sourcesItems;
      };
    in
    mkIf cfg.enable {
      programs.nixneovim = {
        extraPlugins = with pkgs.vimPlugins; [ null-ls-nvim ];

        extraConfigLua = ''
          require("null-ls").setup(${helpers.converter.toLuaObject options})
        '';
      };
    };
}
