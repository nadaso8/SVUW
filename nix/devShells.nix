# Defines all devShells for the flake
{ system, pkgs, inputs }:
let
  inherit (inputs) fenix;
  rustToolchain = fenix.packages.${system}.fromToolchainFile {
    file = ../rust-toolchain.toml;
    sha256 = "sha256-+9FmLhAOezBZCOziO0Qct1NOrfpjNsXxc/8I0c7BdKE=";
  };
  rustPlatform = pkgs.makeRustPlatform {
    inherit (rustToolchain) cargo rustc;
  };
in
{
  default = pkgs.mkShell {
    # These programs be available to the dev shell
    buildInputs = (with pkgs; [
      nixpkgs-fmt
    ]) ++ pkgs.lib.optional pkgs.stdenv.isDarwin [
      pkgs.libiconv
    ] ++ [
      rustToolchain
      rustPlatform.bindgenHook
    ];

    # Hook the shell to set custom env vars
    shellHook = ''
    '';
  };
}