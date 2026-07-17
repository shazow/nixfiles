{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pythonPkg = pkgs.python313;

        mkShell = python: packages:
          pkgs.mkShell {
            packages = [
              (python.withPackages packages)
            ];

            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
              pkgs.stdenv.cc.cc.lib
              pkgs.zlib
            ];

            shellHook = ''
              export PYTHONPATH="$PWD/src''${PYTHONPATH:+:$PYTHONPATH}"
            '';
          };
      in {
        devShells = {
          default = mkShell pythonPkg (ps: with ps; [
            # formatting/lint hooks from .pre-commit-config.yaml.
            pyupgrade
            black
            isort
            flake8

            # Bare pyproject dependency-groups.test.
            anyio
            h2
            httpx
            hypercorn
            pysocks
            pytest
            pytest-socket
            pytest-timeout
            quart
            quart-trio
            trio
            trustme

            # pyproject dependency-groups.mypy
            types-requests
            #types-pysocks # Not in nixpkgs
            mypy
            nox
            memray

            # Only needed on Python < 3.14 per marker.
            backports-zstd

            brotli
            cryptography
            idna
            trustme
            pyopenssl

            uv
          ]);
        };
      });
}
