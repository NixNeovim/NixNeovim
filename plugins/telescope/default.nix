{ pkgs, lib, config, ... }:
with lib;
let

  name = "telescope";
  pluginUrl = "https://github.com/nvim-telescope/telescope.nvim";

  helpers = import ../../helper { inherit pkgs lib config; };
  cfg = config.programs.nixneovim.plugins.${name};
  inherit (helpers) toLuaObject;
  inherit (helpers.customOptions) attrsOption boolOption;
  inherit (helpers.toLua) convertModuleOptions;

  extensions = import ./modules/extensions.nix {
    inherit pkgs lib helpers;
    cfg-telescope = cfg;
  };

  moduleOptions = with helpers; {
    # add module options here
    useBat = boolOption true "Use bat as the previewer instead of cat";
    highlightTheme = mkOption {
      type = types.nullOr types.str;
      description = "The colorscheme to use for syntax highlighting";
      default = config.programs.nixneovim.colorscheme;
    };
    extraPickersConfig = attrsOption { } "Put extra config for the builtin pickers here";
    extraExtensionsConfig = attrsOption { } "Put extra config for extensions here";
    extensions = extensions.options;
  };

  pluginOptions = convertModuleOptions cfg moduleOptions;

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    telescope-nvim
    plenary-nvim
    popup-nvim
  ] ++ extensions.plugins;
  # ];
  extraPackages = with pkgs; [
    manix
    ripgrep
  ] ++ optional cfg.useBat bat
  ++ extensions.packages;

  # this looks weird but produces correctly indended lua code
  extraConfigLua =
    ''
      local telescope = require('${name}')
          telescope.setup {
            extensions = ${ extensions.config },
          }
          ${toLuaObject pluginOptions}

          ${ concatStringsSep "\n    " extensions.loadString } '';
}

#   # imports = [
#   #   ./frecency.nix
#   #   ./fzf-native.nix
#   #   ./fzy-native.nix
#   # ];

#   options.programs.nixneovim.plugins.telescope = {
#     enable = mkEnableOption "Enable telescope.nvim";

#     # extensionConfig = mkOption {
#     #   type = types.attrsOf types.anything;
#     #   description = "Configuration for the extensions. Don't use this directly";
#     #   default = {};
#     # };
#   };

#   config = mkIf cfg.enable {
#     programs.nixneovim = {
#       # extraPackages = [ pkgs.bat ];

#       # extraPlugins = with pkgs.vimPlugins; [
#       #   telescope-nvim
#       #   plenary-nvim
#       #   popup-nvim
#       # ];

#       extraConfigVim = mkIf (cfg.highlightTheme != null) ''
#         let $BAT_THEME = '${cfg.highlightTheme}'
#       '';

#       #   local __telescopeExtensions = ${helpers.toLuaObject cfg.enabledExtensions}

#       #   require('telescope').setup{
#       #     extensions = ${helpers.toLuaObject cfg.extensionConfig}
#       #   }

#       #   for i, extension in ipairs(__telescopeExtensions) do
#       #     require('telescope').load_extension(extension)
#       #   end
#     };
#   };
# }
