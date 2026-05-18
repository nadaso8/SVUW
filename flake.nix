{
  description = "SVUW flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    
    # linux
    nixos-25_11.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # darwin
    nixpkgs-25_11-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

  };

  outputs = inputs-raw@{ flake-utils, ... }: 
  let
    systems = with flake-utils.lib.system; [x86_64-linux aarch64-linux];
    perSystem = (system: rec {
      inputs = import ./nix/inputs.nix { inherit inputs-raw system; };
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          ((import nix/overlays/nixpkgs-unstable.nix) {inherit inputs;})
        ];
        config = {
          # allowUnfree = true;
        };
      };
    });
    inherit (flake-utils.lib.eachSystem systems (system: { s = perSystem system; })) s;
  in
  flake-utils.lib.eachSystem systems
    (system: 
      let 
        inherit (s.${system}) pkgs inputs; 
      in 
      {
        devShells = import ./nix/devShells.nix { inherit system pkgs inputs; };
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}