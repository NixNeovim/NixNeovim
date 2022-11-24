{ pkgs, lib, nmd, ... }:
let

  nmd = import nmd { inherit pkgs lib; };

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
        "https://github.com/pta2002/nixvim/blob/master/${path}#blob-path";
      channelName = "nixvim";
    } // args);

  nixvimDocs = buildModulesDocs {
    modules = [
      (import ../nixvim.nix { pkgs = pkgs;})
      scrubbedPkgsModule
    ];
    docBook.id = "nixvim-options";
  };

  docs = nmd.buildDocBookDocs {
    pathName = "";
    modulesDocs = [ nixvimDocs ];
    documentsDirectory = ./.;
    documentType = "book";
    chunkToc = ''
      <toc>
        <d:tocentry xmlns:d="http://docbook.org/ns/docbook" linkend="book-home-manager-manual"><?dbhtml filename="index.html"?>
          <d:tocentry linkend="ch-options"><?dbhtml filename="options.html"?></d:tocentry>
          <d:tocentry linkend="ch-release-notes"><?dbhtml filename="release-notes.html"?></d:tocentry>
        </d:tocentry>
        </toc>
      '';
  };
in docs.html
