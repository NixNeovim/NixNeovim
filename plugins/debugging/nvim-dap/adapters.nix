{ lib, pkgs, helpers, ... }:


let

  inherit (helpers.custom_options) strNullOption;

  inherit (lib)
    submodule
    mkOption;
  inherit (lib.type)
    enum
    listOf
    str
    nullOr;

  adapterType = submodule {
    options = {
      type = mkOption {
        type = enum [ "executable" "server" ];
        default = "executable";
      };
      command = strNullOption "";
      args = mkOption {
        type = listOf str;
        default = [ ];
      };
    };
  };

in
{
  rust = mkOption {
    type = nullOr adapterType;
    default = null;
  };
}
