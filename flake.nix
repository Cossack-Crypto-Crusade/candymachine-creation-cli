{
  description = "Development environment for candymachine-creation-cli";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";  # or a stable pin you prefer
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        node = pkgs.nodejs-20_x;  # use Node 20

        # pnpm from nodePackages
        pnpm = node.nodePackages.pnpm;

      in {
        devShells.default = pkgs.mkShell {
          name = "candymachine-dev";

          buildInputs = [
            node
            pnpm
            # add any other CLI tools your project needs, e.g.
            # git, openssl, etc.
            pkgs.git
          ];

          # Optionally set up environment variables or hooks
          shellHook = ''
            # ensure pnpm uses the right node version
            export PATH=${node}/bin:$PATH
            echo "Using node $(node --version)"
            echo "Using pnpm $(pnpm --version)"
          '';
        };

        # Optionally you can expose a `package` output to build the project
        packages.default = pkgs.stdenv.mkDerivation {
          name = "candymachine-cli";
          src = ./.;

          buildInputs = [ node pnpm ];

          # The build phase: install via pnpm and build
          buildPhase = ''
            pnpm install
            pnpm run build
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp -r dist/* $out/bin/
          '';
        };
      });
}
