{ lib }:

let
  inherit (lib.types)
    submodule;

  inherit (lib)
    mkOption
    mkEnableOption;

  luaSnipOptions = submodule {
    options = {
      enable = mkEnableOption "";
    };
  };

in mkOption {
  type = submodule {
    options = {
      luasnip = mkOption {
        type = luaSnipOptions;
      };
    };
  };
}
