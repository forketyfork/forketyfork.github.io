{
  description = "Jekyll dev shell with reproducible Ruby environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        # Use Ruby 3.4.3 to match Gemfile specification and ensure Jekyll 4.4.1 compatibility
        ruby = pkgs.ruby_3_4;

        # Check that gemset.nix is up-to-date with Gemfile.lock
        ensureGemsetIsFresh = pkgs.runCommand "ensure-gemset-fresh" {
          buildInputs = [ pkgs.bundix ];
        } ''
          echo "Checking if gemset.nix is up to date with Gemfile.lock..."
          if ! bundix --quiet --check; then
            echo "ERROR: gemset.nix is out of date. Run: bundix --lock" >&2
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
        # Development shell
        devShells.default = pkgs.mkShell {
          inputsFrom = [ ensureGemsetIsFresh ];
          buildInputs = [ 
            ruby 
            pkgs.bundix 
            gemset 
            pkgs.nixfmt-classic
            pkgs.nil
            pkgs.yarn
            pkgs.nodejs
          ];

          shellHook = ''
            echo "Jekyll development environment ready!"
            echo "Available commands:"
            echo "  bundle exec jekyll serve --source jekyll  # Start development server"
            echo "  bundix --lock                             # Update gemset.nix"
            echo "  yarn build                                # Build webpack assets"
            echo "  nixfmt flake.nix                          # Format Nix files"
          '';
        };

        # Package outputs - provides access to the Jekyll gem environment
        packages = {
          default = gemset;      # Default package (nix build)
          jekyll-env = gemset;   # Named Jekyll environment package
        };      }
    );
}