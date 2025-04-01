{
  description = "Jekyll dev shell with reproducible Ruby environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        ruby = pkgs.ruby_3_4;

        # Check that gemset.nix is up-to-date with Gemfile.lock
        ensureGemsetIsFresh = pkgs.runCommand "ensure-gemset-fresh" {
          buildInputs = [ pkgs.bundix ];
        } ''
          echo "Checking if gemset.nix is up to date with Gemfile.lock..."
          if ! bundix --quiet --check; then
            echo "ERROR: gemset.nix is out of date. Run: bundix" >&2
            exit 1
          fi
          touch $out
        '';

        gemset = pkgs.bundlerEnv {
          name = "jekyll-env";
          ruby = ruby;
          gemdir = ./.;
        };

      in {
        devShell = pkgs.mkShell {
          inputsFrom = [ ensureGemsetIsFresh ];
          buildInputs = [ ruby pkgs.bundix gemset ];

          shellHook = ''
            export GEM_HOME=$PWD/.gems
            export PATH=$GEM_HOME/bin:$PATH
            echo "Ready to go. Use: bundle exec jekyll serve"
          '';
        };
      }
    );
}