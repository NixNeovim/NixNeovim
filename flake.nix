{
  description = "A neovim configuration system for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nmd = {
      url = "gitlab:rycee/nmd";
      flake = false;
    };
    nmt = {
      url = "github:jooooscha/nmt"; # slightly modified version of rycee/nmt
      flake = false;
    };

    nixneovimplugins.url = "github:nixneovim/nixneovimplugins";
    nix-flake-tests.url = "github:antifuchs/nix-flake-tests";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, nmd, nmt, nix-flake-tests, ... }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; overlays = [ inputs.nixneovimplugins.overlays.default ]; };

      lib = pkgs.lib;

    in
    {
      packages.${system}.docs = import ./docs {
        inherit pkgs;
        lib = nixpkgs.lib;
        nmd = import nmd { inherit pkgs lib; };
      };

      nixosModules = {
        default = import ./nixneovim.nix { homeManager = true; };
        homeManager = self.nixosModules.default;
        homeManager-22-11 = import ./nixneovim.nix { homeManager = true; state = 2211; };
        nixos = import ./nixneovim.nix { homeManager = false; };
        nixos-22-11 = import ./nixneovim.nix { homeManager = false; state = 2211; };
      };

      overlays.default = inputs.nixneovimplugins.overlays.default;

      lib = import ./lib.nix;

      checks =
        let
          nmt-tests = {
            x86_64-linux = import ./tests {
              inherit nmt pkgs;
              nixneovim = self.nixosModules.homeManager;
              inherit (inputs) home-manager;
            };
          };

          lib-checks = {
            x86_64-linux.basic = nix-flake-tests.lib.check {
              inherit pkgs;
              tests = pkgs.callPackage ./tests.nix {};
            };
          };
        in lib.recursiveUpdate nmt-tests lib-checks;

       # devShells = forAllSystems (system:
       #  let
       #    pkgs = nixpkgs.legacyPackages.x86_64-linux;
       #    tests = import ./tests { inherit lib pkgs nmt; };
       #  in {
       #    default = tests.run;
       #  });

      # devShells.x86_64-linux.default = import nmt {
      #     inherit lib pkgs modules;
      #     testedAttrPath = [ "home" "activationPackage" ];
      #     tests = {
      #       testa = {
      #       config = {
      #         programs.neovim = {
      #           enable = true;
      #           extraConfig = ''
      #             let g:hmExtraConfig='HM_EXTRA_CONFIG'
      #               '';
      #               plugins = with pkgs.vimPlugins; [
      #                 vim-nix
      #                 {
      #                   plugin = vim-commentary;
      #                   config = ''
      #                     let g:hmPlugins='HM_PLUGINS_CONFIG'
      #                   '';
      #                 }
      #               ];
      #               extraLuaPackages = [ pkgs.lua51Packages.luautf8 ];
      #             };

      #             nmt.script = ''
      #               vimout=$(mktemp)
      #               echo "redir >> /dev/stdout | echo g:hmExtraConfig | echo g:hmPlugins | redir END" \
      #                 | ${pkgs.neovim}/bin/nvim -es -u "$TESTED/home-files/.config/nvim/init.lua" \
      #                 > "$vimout"
      #               assertFileContains "$vimout" "HM_EXTRA_CONFIG"
      #               assertFileContains "$vimout" "HM_PLUGINS_CONFIG"
      #             '';
      #           };
      #       };
      #     };
      #   };

      # apps.${system} = {
      #   default = {
      #     type = "app";
      #     program = "${self.packages.${system}.default}/bin/nvim";
      #   };
      # };

      # packages.${system}.default = pkgs.wrapNeovim pkgs.neovim-unwrapped {
      #   configure = {
      #     customRC = ''
      #       set number relativenumber
      #     '';
      #   };
      # };

    };
}
