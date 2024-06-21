{ homeManager ? true, isDocsBuild ? false, state ? 9999, haumea }: # function that returns a package
{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.programs.nixneovim;

  mappings = helpers.keymapping;

  inherit (helpers) augroups;

  pluginWithConfigType = types.submodule {
    options = {
      config = mkOption {
        type = types.lines;
        description = "vimscript for this plugin to be placed in init.vim";
        default = "";
      };

      optional = mkEnableOption "optional" // {
        description = "Don't load by default (load with :packadd)";
      };

      plugin = mkOption {
        type = types.package;
        description = "vim plugin";
      };
    };
  };

  helpers = haumea.lib.load {
    src = ./helpers;
    inputs = {
      inherit lib config;
      usePluginDefaults = config.programs.nixneovim.usePluginDefaults;
    };
  };

  plugins =
    let
      src = haumea.lib.load {
        src = ./src;
        inputs = {
          inherit helpers config pkgs lib state;
        };
      };
    in src.plugins //
      src.environments //
      src.colorschemes;


in {

  imports = [
    { imports = lib.mapAttrsToList (key: value: value) plugins; }
  ];

  options = {
    programs.nixneovim = {
      enable = mkEnableOption "enable nixneovim";

      defaultEditor = mkOption {
        type = types.bool;
        default = false;
        description = "Configures neovim to be the default editor using the EDITOR environment variable.";
      };

      viAlias = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Symlink <command>vi</command> to <command>nvim</command> binary.
        '';
      };

      vimAlias = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Symlink <command>vim</command> to <command>nvim</command> binary.
        '';
      };

      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = "The package to use for neovim.";
      };

      extraPlugins = mkOption {
        type = with types; listOf (either package pluginWithConfigType);
        default = [ ];
        description = "List of vim plugins to install.";
      };

      usePluginDefaults = mkOption {
        type = types.bool;
        default = false;
        description = ''
          When false, NixNeovim will output the lua config with all available options.
          This way, when a default in a plugin changes, your config will stay the same.

          When true, NixNeovim will output the lua config only with options you have set in you config.
          This way, all other values will have the default set by the plugin author.
          When the defaults change, your setup will change.

          Setting this to true, will significantly reduce the number of lines in your init.lua, depending on the number of plugins enabled.
        '';
      };

      colorscheme = mkOption {
        type = types.nullOr types.str;
        description = "The name of the colorscheme";
        default = null;
      };

      extraConfigLua = mkOption {
        type = types.lines;
        default = "";
        description = "Extra contents for init.lua";
      };

      extraLuaPreConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Extra contents for init.lua before everything else";
      };

      extraLuaPostConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Extra contents for init.lua after everything else";
      };

      extraConfigVim = mkOption {
        type = types.lines;
        default = "";
        description = "Extra contents for init.vim";
      };

      extraPackages = mkOption {
        type = types.listOf types.package;
        default = [ ];
        example = "[ pkgs.shfmt ]";
        description = "Extra packages to be made available to neovim";
      };

      configure = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = "Internal option";
      };

      options = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = "The configuration options, e.g. line numbers";
      };

      globals = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = "Global variables";
      };

      mappings = mkOption {
        type = types.submodule {
          options =
            let
              inherit (mappings) mapOptions;
            in {
              normal = mapOptions "normal";
              insert = mapOptions "insert";
              select = mapOptions "select";
              visual = mapOptions "visual and select";
              terminal = mapOptions "terminal";
              normalVisualOp = mapOptions "normal, visual, select and operator-pending (same as plain 'map')";

              visualOnly = mapOptions "visual only";
              operator = mapOptions "operator-pending";
              insertCommand = mapOptions "insert and command-line";
              lang = mapOptions "insert, command-line and lang-arg";
              command = mapOptions "command-line";
            };
        };
        default = { };
        description = ''
          Custom keybindings for any mode.

          For plain maps (e.g. just 'map' or 'remap') use maps.normalVisualOp.
        '';

        example = ''
          maps = {
            normalVisualOp.";" = ":"; # Same as noremap ; :
            normal."<leader>m" = {
              silent = true;
              action = "<cmd>make<CR>";
            }; # Same as nnoremap <leader>m <silent> <cmd>make<CR>
          };
        '';
      };

      augroups = mkOption {
        default = { };
        type = types.attrsOf (types.submodule augroups.augroupOptions);
        description = ''
          Custom autocmd groups
        '';
        example = ''
          augroups.highlightOnYank = {
            autocmds = [{
              event = "TextYankPost";
              pattern = "*";
              luaCallback = ''\''
                vim.highlight.on_yank {
                  higroup = (
                    vim.fn['hlexists'] 'HighlightedyankRegion' > 0 and 'HighlightedyankRegion' or 'IncSearch'
                  ),
                  timeout = 200,
                }
              ''\'';
            }];
          };
        '';
      };
    };

  };

  config =
    let
      neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
        configure = cfg.configure;
        plugins = cfg.extraPlugins;
      };

      extraWrapperArgs = optionalString (cfg.extraPackages != [ ])
        ''--prefix PATH : "${makeBinPath cfg.extraPackages}"'';

      package = if (cfg.package != null) then cfg.package else pkgs.neovim;

      wrappedNeovim = pkgs.wrapNeovimUnstable package (neovimConfig // {
        wrapperArgs = lib.escapeShellArgs neovimConfig.wrapperArgs + " "
          + extraWrapperArgs;
      });

      luaGlobals =
        let
          list = mapAttrsToList
            (option: value:
              "vim.g.${option} = ${helpers.converter.toLuaObject value}"
            )
            cfg.globals;
        in concatStringsSep "\n" list;

      luaOptions =
        let
          list = mapAttrsToList
            (option: value:
              "vim.o.${option} = ${helpers.converter.toLuaObject value}"
            )
            cfg.options;
        in concatStringsSep "\n" list;


      luaConfig = ''
        ${cfg.extraLuaPreConfig}
        --------------------------------------------------
        --                 Globals                      --
        --------------------------------------------------

        ${luaGlobals}

        --------------------------------------------------
        --                 Options                      --
        --------------------------------------------------

        ${luaOptions}

        --------------------------------------------------
        --                 Keymappings                  --
        --------------------------------------------------

        ${mappings.luaString cfg.mappings}

        --------------------------------------------------
        --                 Augroups                     --
        --------------------------------------------------

        ${augroups.luaString cfg.augroups}

        --------------------------------------------------
        --               Extra Config (Lua)             --
        --------------------------------------------------

        ${cfg.extraConfigLua}

        ${
          # Set colorscheme after setting globals.
          # Some colorschemes depends on variables being set before setting the colorscheme.
          optionalString
            (cfg.colorscheme != "" && cfg.colorscheme != null)
            "vim.cmd([[colorscheme ${cfg.colorscheme}]])"
        }

        ${cfg.extraLuaPostConfig}
      '';

      configure = {
        # Make sure that globals are set before plugins are setup.
        # This is becuase you might want to define variables or global functions
        # that the plugin configuration depend upon.
        customRC =
          cfg.extraConfigVim
          + luaConfig;

        packages.nixneovim = {
          start = filter (f: f != null) (map
            (x:
              if x ? plugin && x.optional == true then null else (x.plugin or x))
            cfg.extraPlugins);
          opt = filter (f: f != null)
            (map (x: if x ? plugin && x.optional == true then x.plugin else null)
              cfg.extraPlugins);
        };
      };


    in (mkIf cfg.enable (
      if isDocsBuild then { }
      else if homeManager then
        {
          programs.neovim = {
            enable = true;
            # defaultEditor = cfg.defaultEditor;
            viAlias = cfg.viAlias;
            vimAlias = cfg.vimAlias;
            package = mkIf (cfg.package != null) cfg.package;
            extraPackages = cfg.extraPackages;
            extraConfig = cfg.extraConfigVim;
            extraLuaConfig = luaConfig;
            plugins = cfg.extraPlugins;
          } // (optionalAttrs (state > 2211) { defaultEditor = cfg.defaultEditor; }); # only add defaultEditor when over nixpkgs release 22-11
        }
      else
        {
          environment.systemPackages = [ wrappedNeovim ];
          programs.neovim = {
            defaultEditor = cfg.defaultEditor;
            viAlias = cfg.viAlias;
            vimAlias = cfg.vimAlias;
            configure = configure;
          };

          environment.etc."xdg/nvim/sysinit.vim".text = neovimConfig.neovimRcContent;
        }
    ));
}
