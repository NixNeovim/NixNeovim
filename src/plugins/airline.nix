{ pkgs, lib, helpers, config }:

let

  inherit (helpers.generator)
     mkLuaPlugin;

  name = "airline";
  pluginUrl = "https://github.com/vim-airline/vim-airline";

  cfg = config.programs.nixneovim.plugins.${name};

  sectionType = with lib.types; nullOr (oneOf [ str (listOf str) ]);

  sectionOption = lib.mkOption {
    default = null;
    type = sectionType;
    description = "Configuration for this section. Can be either a statusline-format string or a list of modules to be passed to airline#section#create_*.";
  };

  inherit (helpers.custom_options)
    strOption
    attrsOption
    listOption
    enumOption
    intOption
    boolOption;

  moduleOptionsVim = {
    # add module options here
    extensions = attrsOption {} "A list of extensions and their configuration";
    onTop = boolOption false "Whether to show the statusline on the top instead of the bottom";

    sections = lib.mkOption {
      description = "Statusbar sections";
      default = null;
      type = with lib.types; nullOr (submodule {
        options = {
          a = sectionOption;
          b = sectionOption;
          c = sectionOption;
          x = sectionOption;
          y = sectionOption;
          z = sectionOption;
        };
      });
    };

    powerline = boolOption false "Whether to use powerline symbols";

    theme = strOption "" "The theme to use for vim-airline. If set, vim-airline-themes will be installed.";
  };
in mkLuaPlugin {

# Consider the following additional options:
#
# extraDescription ? ""           # description added to the enable function
# extraPackages ? [ ]             # non-plugin packages
# extraConfigLua ? ""             # lua config added to the init.vim
# extraConfigVim ? ""             # vim config added to the init.vim
# defaultRequire ? true           # add default requrie string?
# extraOptions ? {}               # extra vim options like line numbers, etc
# extraNixNeovimConfig ? {}       # extra config applied to 'programs.nixneovim'
# isColorscheme ? false           # If enabled, plugin will be added to 'nixneovim.colorschemes' instead of 'nixneovim.plugins'
# configConverter ? camelToSnake  # Specify the config name converter, default expects camelCase and converts that to snake_case
# moduleOptions                   # define (lua) configuration options for the plugin here
# moduleOptionsVim                # define (vim) configuration options for the plugin here
# moduleOptionsVimPrefix          # when using 'moduleOptionsVim' you can use this to define the options prefix. For example, "NERD" (for NerdCommenter), or "ledger_" (for ledger)

  inherit name moduleOptionsVim pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    vim-airline
  ] ++ optional (!isNull cfg.theme) vim-airline-themes;
}
  # config =
  #     programs.nixneovim = {
  #       extraPlugins = with pkgs.vimPlugins; [
  #       ] ++ optional (!isNull cfg.theme) vim-airline-themes;
  #       globals = {
  #         airline.extensions = cfg.extensions;

  #         airline_statusline_ontop = mkIf cfg.onTop 1;
  #         airline_powerline_fonts = mkIf (cfg.powerline) 1;

  #         airline_theme = mkIf (!isNull cfg.theme) cfg.theme;
  #       };
  #     };
  #   };
