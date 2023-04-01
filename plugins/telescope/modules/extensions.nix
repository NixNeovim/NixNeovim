{ pkgs, lib, helpers, cfg-telescope }:

let

  cfg-extensions = cfg-telescope.extensions;
  filters = helpers.filters { cfg = cfg-extensions; };

  inherit (helpers.customOptions) strOption;
  inherit (helpers)
    camelToSnake;
  inherit(lib)
    types
    mkEnableOption
    forEach
    mapAttrs
    mapAttrs'
    mkOption;
  inherit (filters)
    activated
    activatedPlugins
    activatedPackages
    activatedLuaNames;

  extensionsSet = with pkgs.vimExtraPlugins; {
    manix = {
      plugins = [ telescope-manix ];
      packages = [ pkgs.manix ];
    };
    mediaFiles = {
      luaName = "media_files";
      plugins = [ telescope-media-files-nvim popup-nvim plenary-nvim ];
      packages = [ pkgs.ueberzug ];
      options = {
        findCmd = strOption "" "";
      };
    };
  };

  mkExtension = name: extensionConfig: mkOption {
    type = types.submodule {
      options =
        let
          defaultOptions = {
            enable = mkEnableOption "Enable ${name}";
            extraConfig = mkOption {
              type = types.attrs;
              default = { };
            };
          };
        in
        defaultOptions // extensionConfig.options;
    };
    description = "Enable the ${name} telescope extension";
    default = { };
  };

  extensions = mapAttrs
    (
      name: { plugins, luaName ? name, packages ? { }, extraConfig ? { }, options ? { } }:
        { inherit plugins luaName packages extraConfig options; }
    )
    extensionsSet;
in {

  # nix module options for all soruces
  options = mapAttrs mkExtension extensions;

  # list of packages that actiated sources depend on
  packages = activatedPackages extensions;

  # list of packages that actiated sources depend on
  plugins = activatedPlugins extensions;

  # string list of all extensions that shall be loaded
  loadString = forEach (activatedLuaNames extensions) (ext: "telescope.load_extension('${ext}')");

  config = helpers.toLuaObject (
    mapAttrs'
      (name: attrs:
        {
          name = attrs.luaName;
          value = mapAttrs'
            (optName: _:
              {
                name = camelToSnake optName;
                value = cfg-extensions.${name}.${optName};
              }
            )
            attrs.options;
        }
      )
      (activated extensions));

}
