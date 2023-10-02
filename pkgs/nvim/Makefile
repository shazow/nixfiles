test:
	nix eval --impure --expr 'import ./tests.nix { inherit (import <nixpkgs> {}) lib stdenv; }'

check:
	nix flake check .  --no-build
