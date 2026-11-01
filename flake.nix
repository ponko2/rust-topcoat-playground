{
  description = "rust-topcoat-playground";

  inputs = {
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    inputs@{ fenix, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      perSystem =
        { pkgs, system, ... }:
        let
          rust-toolchain = pkgs.fenix.fromToolchainFile {
            file = ./rust-toolchain.toml;
            sha256 = "+xUr6Al1wZSqX8aEsq7DpuFOK4Ve/i+qTl+K5uWQ9GM=";
          };
          rust-platform = pkgs.makeRustPlatform {
            cargo = rust-toolchain;
            rustc = rust-toolchain;
          };
          topcoat-cli = rust-platform.buildRustPackage (finalAttrs: {
            pname = "topcoat-cli";
            version = "0.11.0";
            src = pkgs.fetchCrate {
              inherit (finalAttrs) pname version;
              hash = "sha256-x9hEjO3Zx+o/onCwmIAD6uVJ+DJHaJV9KUBnDNFlS5U=";
            };
            cargoHash = "sha256-udepDW8t6mM2CSPdCFVdffY7n8ZsgiHtOAZMOUTEhz0=";
            cargoTestFlags = [ "--locked" ];
            doCheck = false;
          });
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              fenix.overlays.default
            ];
          };
          apps = {
            deadnix = {
              type = "app";
              program = "${pkgs.deadnix}/bin/deadnix";
            };
            statix = {
              type = "app";
              program = "${pkgs.statix}/bin/statix";
            };
          };
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              cargo-features-manager
              cargo-nextest
              cargo-shear
              cargo-sort
              deadnix
              nixfmt
              rust-analyzer
              rust-toolchain
              statix
              topcoat-cli
            ];
          };
          formatter = pkgs.nixfmt-tree;
        };
    };
}
