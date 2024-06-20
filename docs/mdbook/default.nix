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

      names =
        lib.mapAttrsToList
        (name: opt:
          let
            module = opt.options.programs.nixneovim.plugins.${name};
            configOptions = lib.mapAttrsToList (k: v: "programs.nixneovim.plugins.${name}.${k}") module;
          in ''
              cat << EOF > ./${name}-options.md
                ${module.enable.description}

                ${builtins.concatStringsSep "\n\n" configOptions}
              EOF
            '')
        src.plugins;

      paths =
        lib.mapAttrsToList
        (name: opt: "  - [${name}](./${name}-options.md)")
        src.plugins;

    in {
      names = names;
      paths = paths;
    };

  writePaths = builtins.concatStringsSep "\n" modules.names;

  nixneovim-docs = ''
    ${builtins.concatStringsSep "\n" modules.paths}
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

      ${writePaths}

      # insert module information
      substituteInPlace ./SUMMARY.md \
        --replace-fail "@NIXNEOVIM_PLUGINS@" "$(cat ${pkgs.writeText "nixvim-options-summary.md" nixneovim-docs})"

      mdbook build
      cp -r ./book/* $dest
    '';
  };
in nixneovim-mdbook
  # docs.html
