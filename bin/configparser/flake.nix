{
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let

        pkgs = import nixpkgs { inherit system; };

        python-with-my-packages = pkgs.python3.withPackages (p: with p; [
          tree-sitter
          (
            buildPythonPackage rec {
              pname = "SLPP";
              version = "1.2.3";
              src = fetchPypi {
                inherit pname version;
                sha256 = "sha256-If3ZMoNICQxxpdMnc+juaKq4rX7MMi9eDMAQEUy1Scg=";
              };
              doCheck = false;
              propagatedBuildInputs = [
                # antlr4-python3-runtime
                six
              ];
            }
          )
        ]);

      in {
        devShells.default =
          pkgs.mkShell {
            name = "Paper Tracker Shell";
            packages = [
              python-with-my-packages
            ];
          };
      }
    );
}
