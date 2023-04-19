{ homeManager ? true, isDocsBuild ? false }: # function that returns a package
{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.programs.nixneovim;

  helpers = import ./helper { inherit pkgs lib config isDocsBuild; };

  mappings = helpers.keymappings;

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

in
{
  imports = [
    ./plugins
  ];

  options = {
    programs.nixneovim = {
      enable = mkEnableOption "enable nixneovim";

      defaultEditor = mkOption {
        type = types.bool;
        default = false;
        description = "Configures neovim to be the default editor using the EDITOR environment variable.";
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
    };
  };

  config =
    let
      neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
        configure = cfg.configure;
        plugins = cfg.extraPlugins;
      };

      environment.variables.EDITOR = mkIf cfg.defaultEditor (mkOverride 900 "nvim");

      extraWrapperArgs = optionalString (cfg.extraPackages != [ ])
        ''--prefix PATH : "${makeBinPath cfg.extraPackages}"'';

      package = if (cfg.package != null) then cfg.package else pkgs.neovim;

      wrappedNeovim = pkgs.wrapNeovimUnstable package (neovimConfig // {
        wrapperArgs = lib.escapeShellArgs neovimConfig.wrapperArgs + " "
          + extraWrapperArgs;
      });

      luaGlobals = optionalString (cfg.globals != { }) ''
        -- Set up globals {{{
        local __nixneovim_globals = ${helpers.toLuaObject cfg.globals}

        for k,v in pairs(__nixneovim_globals) do
          vim.g[k] = v
        end
        -- }}}
      '' + optionalString (cfg.options != { }) ''
        -- Set up options {{{
        local __nixneovim_options = ${helpers.toLuaObject cfg.options}

        for k,v in pairs(__nixneovim_options) do
          vim.o[k] = v
        end
        -- }}}
      '';


      configure = {
        # Make sure that globals are set before plugins are setup.
        # This is becuase you might want to define variables or global functions
        # that the plugin configuration depend upon.
        customRC =
          cfg.extraConfigVim
          + ''
            lua <<EOF
            ${cfg.extraLuaPreConfig}
            --------------------------------------------------
            --                 Globals                      --
            --------------------------------------------------

            ${luaGlobals}

            --------------------------------------------------
            --                 Keymappings                  --
            --------------------------------------------------

            ${mappings.luaString cfg.mappings}

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
            EOF
          '';

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


    in
    mkIf cfg.enable (
      if isDocsBuild then { }
      else if homeManager then
        {
          programs.neovim = {
            enable = true;
            defaultEditor = cfg.defaultEditor;
            package = mkIf (cfg.package != null) cfg.package;
            extraPackages = cfg.extraPackages;
            extraConfig = configure.customRC;
            plugins = cfg.extraPlugins;
          };
        }
      else
        {
          environment.systemPackages = [ wrappedNeovim ];
          programs.neovim = {
            configure = configure;
          };

          environment.etc."xdg/nvim/sysinit.vim".text = neovimConfig.neovimRcContent;
        }
    );
}
