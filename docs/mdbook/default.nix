{ pkgs, lib, nmd, haumea }:
let

  scrubbedPkgsModule = {
    imports = [{
      _module.args = {
        pkgs = lib.mkForce (nmd.scrubDerivations "pkgs" pkgs);
        pkgs_i686 = lib.mkForce { };
      };
    }];
  };

  buildModulesDocs = args:
    nmd.buildModulesDocs ({
      moduleRootPaths = [ ./.. ];
      mkModuleUrl = path:
        "https://github.com/nixneovim/nixneovim/blob/main/${path}#blob-path";
      channelName = "nixneovim";
    } // args);

  nixneovimDocs = buildModulesDocs {
    modules = [
      (import ../nixneovim.nix { isDocsBuild = true; inherit haumea pkgs; })
      scrubbedPkgsModule
    ];
    docBook.id = "nixneovim-options";
  };

  modules =
    let
      helpers = haumea.lib.load {
        src = ../../helpers;
        inputs = {
          inherit lib;
          usePluginDefaults = false;
        };
      };

      src = haumea.lib.load {
        src = ../../src;
        inputs = { inherit helpers lib; };
      };

      # colorschemes = lib.mapAttrsToList (name: _: name) src.colorschemes;
      plugins = lib.mapAttrsToList (name: opt:
          let
          # ''
          #   ## ${name}

          #   ${opt.options.programs.nixneovim.plugins.${name}.enable.description}
          # ''
          in "  - [${name}](./SUMMARY.md#${name})"
        ) src.plugins;

      # out_colorschemes = builtins.concatStringsSep "\n\n" colorschemes;
      out_plugins = builtins.concatStringsSep "\n\n" plugins;
    in out_plugins;

  nixneovim-docs = ''
  OPTIONS
  ${modules}
  '';

  nixneovim-mdbook = pkgs.stdenv.mkDerivation {
    name = "nixneovim-mdbook";
    phases = [ "buildPhase" ];
    buildInputs = [ pkgs.mdbook ];
    # inputs = sourceFilesBySuffices ./. [
    #   ".md"
    #   ".toml"
    #   ".js"
    # ];
    inputs = [
      ./.
    ];
    buildPhase = ''
      dest=$out/share/doc
      mkdir -p $dest

      # copy all needed documentation into scope
      cp -r --no-preserve=all $inputs/* ./

      # insert module information
      substituteInPlace ./SUMMARY.md \
        --replace-fail "@NIXNEOVIM_OPTIONS@" "$(cat ${pkgs.writeText "nixvim-options-summary.md" nixneovim-docs})"

      mdbook build
      cp -r ./book/* $dest
    '';
  };
in nixneovim-mdbook
  # docs.html
