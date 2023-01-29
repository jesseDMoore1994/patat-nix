{
  description = "A flake for building patat";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
    patat-src.url = "github:jaspervdj/patat";
    patat-src.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, patat-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [myNixPkgsOverlay];
        }; 

        myNixPkgsOverlay = (nixSelf: nixSuper: {
          myHaskellPackages = nixSelf.haskellPackages.override (oldHaskellPkgs: {
            overrides = nixSelf.lib.composeExtensions (oldHaskellPkgs.overrides or (_: _: {}))  myHaskellPkgsOverlay;
          });
        });

        myHaskellPkgsOverlay = (hSelf: hSuper: {
          # "myproject" is the first part of the "myproject.cabal" project definition file
          patat = hSelf.callCabal2nix "patat" patat-src {};
        });

      in rec {
        defaultPackage = pkgs.myHaskellPackages.patat;
        apps.patat = flake-utils.lib.mkApp { drv = pkgs.myHaskellPkgsOverlay.patat; };
        defaultApp = apps.patat;
      }
    );
}
