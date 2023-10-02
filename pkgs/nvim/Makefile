test:
	nix eval --impure --expr 'import ./test.nix { inherit (import <nixpkgs> {}) lib stdenv; }'

check:
	nix flake check .  --no-build
