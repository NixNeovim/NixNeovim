{ pkgs, lib, helpers, config }:
with lib;
let
  cfg = config.programs.nixneovim.plugins.specs;

  inherit (helpers.utils)
    rawLua;
in
{
  options.programs.nixneovim.plugins.specs = {
    enable = mkEnableOption "specs-nvim";

    show_jumps = mkOption {
      type = types.bool;
      default = true;
    };

    min_jump = mkOption {
      type = types.int;
      default = 30;
    };

    delay = mkOption {
      type = types.int;
      default = 0;
      description = "Delay in miliseconds";
    };

    increment = mkOption {
      type = types.int;
      default = 10;
      description = "Increment in miliseconds";
    };

    blend = mkOption {
      type = types.int;
      default = 10;
    };

    width = mkOption {
      type = types.int;
      default = 10;
    };

    fader = mkOption {
      type = types.submodule {
        options = {
          builtin = mkOption {
            type = types.nullOr (types.enum [
              "linear_fader"
              "exp_fader"
              "pulse_fader"
              "empty_fader"
            ]);
            default = "linear_fader";
          };

          custom = mkOption {
            type = types.lines;
            default = "";
            example = ''
              function(blend, cnt)
                if cnt > 100 then
                    return 80
                else return nil end
              end
            '';
          };
        };
      };
      default = { builtin = "linear_fader"; };
    };

    resizer = mkOption {
      type = types.submodule {
        options = {
          builtin = mkOption {
            type = types.nullOr
              (types.enum [ "shrink_resizer" "slide_resizer" "empty_resizer" ]);
            default = "shrink_resizer";
          };

          custom = mkOption {
            type = types.lines;
            default = "";
            example = ''
              function(width, ccol, cnt)
                  if width-cnt > 0 then
                      return {width+cnt, ccol}
                  else return nil end
              end
            '';
          };
        };
      };
      default = { builtin = "shrink_resizer"; };
    };

    ignored_filetypes = mkOption {
      type = with types; listOf str;
      default = [ ];
    };

    ignored_buffertypes = mkOption {
      type = with types; listOf str;
      default = [ "nofile" ];
    };

  };
  config =
    let
      setup = helpers.converter.toLuaObject {
        inherit (cfg) show_jumps min_jump;
        ignore_filetypes = attrsets.listToAttrs
          (lib.lists.map (x: attrsets.nameValuePair x true)
            cfg.ignored_filetypes);
        ignore_buftypes = attrsets.listToAttrs
          (lib.lists.map (x: attrsets.nameValuePair x true)
            cfg.ignored_buffertypes);
        popup = {
          inherit (cfg) blend width;
          delay_ms = cfg.delay;
          inc_ms = cfg.increment;
          fader = rawLua (if cfg.fader.builtin == null then
            cfg.fader.custom
          else
            ''require("specs").${cfg.fader.builtin}'');
          resizer = rawLua (if cfg.resizer.builtin == null then
            cfg.resizer.custom
          else
            ''require("specs").${cfg.resizer.builtin}'');
        };
      };
    in
    mkIf cfg.enable {
      programs.nixneovim = {
        extraPlugins = [ pkgs.vimPlugins.specs-nvim ];

        extraConfigLua = ''
          require('specs').setup(${setup})
        '';
      };
    };
}
