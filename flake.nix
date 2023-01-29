{
  description = "A flake for building patat";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    patat-src.url = "github:jaspervdj/patat";
  };

  outputs = { self, nixpkgs, flake-utils, patat-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        }; 
      in rec {
        packages = flake-utils.lib.flattenTree {
          patat = pkgs.stdenv.mkDerivation {
            pname = "patat";
            version = patat-src.rev;
            src = patat-src;
            buildInputs = [
              pkgs.cabal-install
              pkgs.ghc
              pkgs.ghcid
            ];
            buildPhase = ''
              cabal build
            '';
          };
        };
        defaultPackage = packages.patat;
        apps.patat = flake-utils.lib.mkApp { drv = packages.patat; };
        defaultApp = apps.patat;
      }
    );
}
