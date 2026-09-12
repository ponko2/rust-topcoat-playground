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
            version = "0.9.0";
            src = pkgs.fetchCrate {
              inherit (finalAttrs) pname version;
              hash = "sha256-6kLV2AP9e2H8WfmaZ5IwJp3HY3uFD6B0U3qMEvWzWYE=";
            };
            cargoHash = "sha256-o/QffbjjkHqM+mxZwjxARm2mx4ylqxWrRw4UJ4Q0R+Q=";
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
            actionlint = {
              type = "app";
              program = "${pkgs.actionlint}/bin/actionlint";
            };
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
            ghalint = {
              type = "app";
              program = "${pkgs.ghalint}/bin/ghalint";
            };
            oxfmt = {
              type = "app";
              program = "${pkgs.oxfmt}/bin/oxfmt";
            };
            statix = {
              type = "app";
              program = "${pkgs.statix}/bin/statix";
            };
            yamllint = {
              type = "app";
              program = "${pkgs.yamllint}/bin/yamllint";
            };
            zizmor = {
              type = "app";
              program = "${pkgs.zizmor}/bin/zizmor";
            };
          };
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              actionlint
              cargo-features-manager
              cargo-nextest
              cargo-shear
              cargo-sort
              commitlint
              deadnix
              editorconfig-checker
              ghalint
              hk
              nixfmt
              oxfmt
              rust-analyzer
              rust-toolchain
              statix
              topcoat-cli
              yamllint
              zizmor
            ];
          };
          formatter = pkgs.nixfmt-tree;
        };
    };
}
