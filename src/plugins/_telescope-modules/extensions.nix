{ pkgs, lib, helpers, config }:

let

  cfg-extensions = config.programs.nixneovim.plugins.telescope.extensions;

  inherit (helpers.custom_options) strOption;
  inherit (helpers.converter)
    camelToSnake;
  inherit(lib)
    types
    mkEnableOption
    forEach
    mapAttrs
    mapAttrs'
    mkOption;
  inherit (helpers.utils)
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
            enable = mkEnableOption "${name}";
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

  # fills in all missing attributes about an extension
  extensions = mapAttrs
    (
      name: { plugins, luaName ? name, packages ? { }, extraConfig ? { }, options ? { } }:
        { inherit plugins luaName packages extraConfig options; }
    )
    extensionsSet;
in {

  # nix module options for all sources
  options = mapAttrs mkExtension extensions;

  # list of packages that actiated sources depend on
  packages = activatedPackages cfg-extensions extensions;

  # list of packages that actiated sources depend on
  plugins = activatedPlugins cfg-extensions extensions;

  # string list of all extensions that shall be loaded
  loadString = forEach (activatedLuaNames cfg-extensions extensions) (ext: "telescope.load_extension('${ext}')");

  config = helpers.converter.toLuaObject (
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
      (activated cfg-extensions extensions));

}
