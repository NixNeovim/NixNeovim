{ lib, pkgs, config, ... }:

with lib;
with types;
let

  helpers = import ../../../helper { inherit pkgs lib config; };
  inherit (helpers.customOptions) strNullOption;

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
