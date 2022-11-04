{ pkgs, lib, config, ... }:

with lib;

let

  helpers = import ../../helpers.nix { inherit lib config; };

  extensions = { manix = { }; };

  mkExtension = name: options:
    mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable ${name}";
          extraConfig = mkOption {
            type = types.attrs;
            default = { };
          };
        } // options;
      };
      description = "TODO";
      default = { };
    };

in mapAttrs mkExtension extensions

