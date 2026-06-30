{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pythonPkg = pkgs.python312;

        mkShell = python: packages:
          pkgs.mkShell {
            packages = [
              (python.withPackages packages)
            ];

            shellHook = ''
              mkdir -p src/urllib3
              if [ ! -e src/urllib3/_version.py ]; then
                cat > src/urllib3/_version.py <<'PY'
__version__ = "0+local"
PY
              fi

              export PYTHONPATH="$PWD/src''${PYTHONPATH:+:$PYTHONPATH}"
            '';
          };
      in {
        devShells = {
          # Minimum-ish Python formatting/lint hooks from .pre-commit-config.yaml.
          py-hooks = mkShell pythonPkg (ps: with ps; [
            pyupgrade
            black
            isort
            flake8
            flake8-2020
          ]);

          # Bare pyproject dependency-groups.test.
          test-bare = mkShell pythonPkg (ps: with ps; [
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
          ]);

          # Upstream nox mypy session uses Python 3.12.
          mypy = mkShell pythonPkg (ps: with ps; [
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

            # pyproject dependency-groups.mypy
            mypy
            cryptography
            idna
            trustme
            pyopenssl
            types-requests
            types-pysocks
            nox

            # Only needed on Python < 3.14 per marker.
            backports-zstd
          ]);

          # Optional/full-ish test deps, not bare minimum.
          test-extras = mkShell pythonPkg (ps: with ps; [
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

            brotli
            cryptography
            idna
            trustme
            pyopenssl
          ]);

          # Keep this out of Python envs.
          other-hooks = pkgs.mkShell {
            packages = [
              pkgs.uv
              pkgs.nodePackages.prettier
              pkgs.nodePackages.eslint
            ] ++ pkgs.lib.optional (pkgs ? zizmor) pkgs.zizmor;
          };

          default = self.devShells.${system}.test-bare;
        };
      });
}
