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
            sha256 = "p8h3Sl/YRByZfZTAKXdsvF6xEenXKrXSVvpphmZENH4=";
          };
          rust-platform = pkgs.makeRustPlatform {
            cargo = rust-toolchain;
            rustc = rust-toolchain;
          };
          topcoat-cli = rust-platform.buildRustPackage (finalAttrs: {
            pname = "topcoat-cli";
            version = "0.8.0";
            src = pkgs.fetchCrate {
              inherit (finalAttrs) pname version;
              hash = "sha256-j0jxF+5gKPo+5XIorN4yL7p5CSak4xzRNoTK2BGbY3Q=";
            };
            cargoHash = "sha256-f/2O4Fj/jqJfa7mml7xi2aZrd2PgaPeThJHi4cqrdJo=";
            cargoTestFlags = [ "--locked" ];
            doCheck = false;
          });
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              fenix.overlays.default
              (_final: prev: {
                hk = prev.hk.overrideAttrs (oldAttrs: rec {
                  version = "2.0.1";
                  src = prev.fetchFromGitHub {
                    inherit (oldAttrs.src) owner repo;
                    tag = "v${version}";
                    hash = "sha256-Rfl4Ssps+2PUcwj01+srDFPjMq78ec4XWmhgMlbq7iM=";
                  };
                  cargoDeps = rust-platform.fetchCargoVendor {
                    inherit src;
                    hash = "sha256-P6RV8R1hRPkBX0iAfNEiFAuVdcUfg3PpsZ1YB7s2B3E=";
                  };
                });
              })
            ];
          };
          apps = {
            commitlint = {
              type = "app";
              program = "${pkgs.commitlint}/bin/commitlint";
            };
            deadnix = {
              type = "app";
              program = "${pkgs.deadnix}/bin/deadnix";
            };
            editorconfig-checker = {
              type = "app";
              program = "${pkgs.editorconfig-checker}/bin/editorconfig-checker";
            };
            oxfmt = {
              type = "app";
              program = "${pkgs.oxfmt}/bin/oxfmt";
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
              commitlint
              deadnix
              editorconfig-checker
              hk
              nixd
              nixfmt
              oxfmt
              rust-analyzer
              rust-toolchain
              statix
              topcoat-cli
              yamllint
            ];
          };
          formatter = pkgs.nixfmt-tree;
          packages = {
            inherit (pkgs)
              direnv
              nix-direnv
              ;
          };
        };
    };
}
