{
  description = "Jekyll dev shell";

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

        ruby = pkgs.ruby_3_3;

        gemset = pkgs.bundlerEnv {
          name = "jekyll-env";
          ruby = ruby;
          gemdir = ./.;
        };

      in {
        devShell = pkgs.mkShell {
          buildInputs = [ gemset ruby pkgs.bundix ];
          shellHook = ''
            export GEM_HOME=$PWD/.gems
            export PATH=$GEM_HOME/bin:$PATH
            echo "Nix shell ready. Use: bundle exec jekyll serve"
          '';
        };
      }
    );
}