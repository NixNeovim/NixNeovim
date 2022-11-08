{ pkgs, lib, config, ... }:
with lib;
let

  name = "telescope";

  helpers = (import ../helpers.nix { inherit lib config; });
  cfg = config.programs.nixvim.plugins.${name};

  moduleOptions = with helpers; {
    # add module options here
    #
    # autoStart = boolOption true "Enable this pugin at start"
    useBat = boolOption true "Use bat as the previewer instead of cat";
    highlightTheme = mkOption {
      type = types.nullOr types.str;
      description = "The colorscheme to use for syntax highlighting";
      default = config.programs.nixvim.colorscheme;
    };
    extensions = import ./modules/extensions.nix { inherit pkgs config lib; };
  };

in with helpers;
mkLuaPlugin {
  inherit name moduleOptions;
  description = "Enable ${name}.nvim";
  extraPlugins = with pkgs.vimExtraPlugins; [
    telescope-nvim
    plenary-nvim
    popup-nvim
    telescope-manix
  ];
  extraPackages = with pkgs; [
    manix
  ] ++ optional cfg.useBat bat;

  extraConfigLua = let
    enabledExtensions = forEach (attrNames cfg.extensions) (extension:
      optionalString cfg.extensions.${extension}.enable "telescope.load_extension('${extension}')"
    );
  in ''
    local telescope = require('${name}')

    ${ concatStringsSep "\n" enabledExtensions }
  '';
}

#   # imports = [
#   #   ./frecency.nix
#   #   ./fzf-native.nix
#   #   ./fzy-native.nix
#   # ];

#   options.programs.nixvim.plugins.telescope = {
#     enable = mkEnableOption "Enable telescope.nvim";

#     # extensionConfig = mkOption {
#     #   type = types.attrsOf types.anything;
#     #   description = "Configuration for the extensions. Don't use this directly";
#     #   default = {};
#     # };
#   };

#   config = mkIf cfg.enable {
#     programs.nixvim = {
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
