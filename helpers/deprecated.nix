{ lib }:
let

  inherit (lib)
    mapAttrs'
    mapAttrs
    types
    mkIf
    mkOption
    stringLength
    mkEnableOption;

  globalVal = val:
    if builtins.isBool val then
      (if val == false then 0 else 1)
    else val;

in {

  # WARN: deprecated: use mkLuaPlugin
  # mkPlugin = { config, lib, ... }:
  #   { name
  #     , description
  #     , extraPlugins ? [ ]
  #     , extraConfigLua ? ""
  #     , extraConfigVim ? ""
  #     , options ? { }
  #     , ...
  #   }:
  #   let
  #     cfg = config.programs.nixneovim.plugins.${name};
  #     # TODO support nested options!
  #     moduleOptions = (mapAttrs (k: v: v.option) options);
  #     # // {
  #     # extraConfig = mkOption {
  #     #   type = types.attrs;
  #     #   default = {};
  #     #   description = "Place any extra config here as an attibute-set";
  #     # };
  #     # };

  #     globals = mapAttrs'
  #       (name: opt: {
  #         name = opt.global;
  #         value = if cfg.${name} != null then opt.value cfg.${name} else null;
  #       })
  #       options;
  #   in
  #   {
  #     options.programs.nixneovim.plugins.${name} = {
  #       enable = mkEnableOption description;
  #     } // moduleOptions;

  #     config.programs.nixneovim = mkIf cfg.enable {
  #       inherit extraPlugins extraConfigVim globals;
  #       extraConfigLua =
  #         if stringLength extraConfigLua > 0 then
  #           "do -- config scope: ${name}\n" + extraConfigLua + "\nend"
  #         else "";
  #     };
  #   };

  mkDefaultOpt = { type, global, description ? null, example ? null, default ? null, value ? v: (globalVal v), ... }: {
    option = mkOption {
      type = types.nullOr type;
      default = default;
      description = description;
      example = example;
    };

    inherit value global;
  };

  mkNullOrOption = type: desc: lib.mkOption {
    type = lib.types.nullOr type;
    default = null;
    description = desc;
  };

}
