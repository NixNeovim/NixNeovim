{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.programs.nixvim;

in {
  options = {
    programs.nixvim = lib.mkOption {
      type = types.submodule {
        options.enable = mkEnableOption "nixvim";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.finalPackage ];
  } // optionalAttrs (!cfg.wrapRc) {
    xdg.configFile."nvim/init.vim".text = optionalString (!cfg.wrapRc) cfg.initContent;
  };
}
