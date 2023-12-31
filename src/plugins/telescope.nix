{ pkgs, lib, helpers, super, config }:
with lib;
let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "telescope";
  pluginUrl = "https://github.com/nvim-telescope/telescope.nvim";

  cfg = config.programs.nixneovim.plugins.${name};
  inherit (helpers.custom_options) attrsOption boolOption;

  inherit (helpers.converter)
    flattenModuleOptions
    toLuaObject;

  extensions = super.telescope-modules.extensions;

  moduleOptions = with helpers; {
    # add module options here
    # useBat = boolOption true "Use bat as the previewer instead of cat";
    # highlightTheme = mkOption {
    #   type = types.nullOr types.str;
    #   description = "The colorscheme to use for syntax highlighting";
    #   default = config.programs.nixneovim.colorscheme;
    # };
    # extraPickersConfig = attrsOption { } "Put extra config for the builtin pickers here";
    # extraExtensionsConfig = attrsOption { } "Put extra config for extensions here";
    extensions = extensions.options;
  };

  pluginOptions =
    let
      options = flattenModuleOptions cfg (filterAttrs (k: v: k != "extensions") moduleOptions);
      extraConfig = cfg.extraConfig;
    in options // extraConfig;

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    telescope-nvim
    plenary-nvim
    popup-nvim
  ] ++ extensions.plugins;

  extraPackages = with pkgs; [
    manix
    ripgrep
  ] ++ extensions.packages;

  # this looks weird but produces correctly indented lua code
  extraConfigLua =
    ''
      local telescope = require('${name}')
          telescope.setup {
            extensions = ${ extensions.config },
            defaults = ${toLuaObject pluginOptions}
          }

          ${ concatStringsSep "\n    " extensions.loadString } '';

  defaultRequire = false;
}

            # ${toLuaObject cfg.extraConfig}
            # ${toLuaObject pluginOptions}

#   # imports = [
#   #   ./frecency.nix
#   #   ./fzf-native.nix
#   #   ./fzy-native.nix
#   # ];

#   options.programs.nixneovim.plugins.telescope = {
#     enable = mkEnableOption "telescope.nvim";

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

#       #   local __telescopeExtensions = ${helpers.converter.toLuaObject cfg.enabledExtensions}

#       #   require('telescope').setup{
#       #     extensions = ${helpers.converter.toLuaObject cfg.extensionConfig}
#       #   }

#       #   for i, extension in ipairs(__telescopeExtensions) do
#       #     require('telescope').load_extension(extension)
#       #   end
#     };
#   };
# }
