{ pkgs, lib, helpers, config }:
with lib;
let
  cfg = config.programs.nixneovim.plugins.coq;
in
{
  options = {
    programs.nixneovim.plugins.coq = {
      enable = mkEnableOption "coq";

      installArtifacts = mkEnableOption "Install coq-artifacts";

      autoStart = mkOption {
        type = with types; nullOr (oneOf [ bool (enum [ "shut-up" ]) ]);
        default = null;
        description = "Auto-start or shut up";
      };

      recommendedKeymaps = mkOption {
        type = with types; nullOr bool;
        default = null;
        description = "Use the recommended keymaps";
      };
    };
  };
  config =
    let
      settings = {
        auto_start = cfg.autoStart;
        "keymap.recommended" = cfg.recommendedKeymaps;
      };
    in
    mkIf cfg.enable {
      programs.nixneovim = {
        extraPlugins = [
          # plugins.coq-nvim
          pkgs.vimExtraPlugins.coq-nvim
        ] ++ optional cfg.installArtifacts pkgs.vimExtraPlugins.coq-artifacts;
        plugins.lspconfig = {
          preConfig = ''
            vim.g.coq_settings = ${helpers.converter.toLuaObject settings}
          '';
          coqSupport = true;
        };
      };
    };
}
