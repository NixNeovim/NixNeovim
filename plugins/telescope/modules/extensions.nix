{ pkgs, lib, config, ... }:

with lib;
with pkgs;
with pkgs.vimExtraPlugins;

let

  cfg-plugin = config.programs.nixneovim.plugins.telescope.extensions;
  helpers = import ../../helpers.nix { inherit lib config cfg-plugin; };

  extensionsSet = {
    manix = {
      plugins = [ telescope-manix ];
      packages = [ manix ];
    };
    mediaFiles = {
      luaName = "media_files";
      plugins = [ telescope-media-files-nvim popup-nvim plenary-nvim ];
      packages = [ ueberzug ];
      options = {
        findCmd = helpers.strOption "" "";
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
in
with helpers; {

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
                value = cfg-plugin.${name}.${optName};
              }
            )
            attrs.options;
        }
      )
      (helpers.activated extensions));

}
