{ lib, config, pkgs, ... }:

with lib;
with types;
let

  luaSnipOptions = submodule {
    options = {
      enable = mkEnableOption "";
    };
  };


in
mkOption {
  type = submodule {
    options = {
      luasnip = mkOption {
        type = luaSnipOptions;
      };
    };
  };
}
